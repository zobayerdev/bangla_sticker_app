package com.example.sticker_flutter

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ContentResolver
import android.content.Intent
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.sticker_flutter/whatsapp"
    private val ADD_PACK_REQUEST_CODE = 200
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isWhatsAppInstalled" -> {
                    val isInstalled = isPackageInstalled("com.whatsapp") || isPackageInstalled("com.whatsapp.w4b")
                    result.success(isInstalled)
                }
                "getStickersDir" -> {
                    val dir = File(filesDir, "stickers")
                    if (!dir.exists()) {
                        dir.mkdirs()
                    }
                    result.success(dir.absolutePath)
                }
                "isPackAdded" -> {
                    val identifier = call.argument<String>("identifier")
                    if (identifier.isNullOrEmpty()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    val isAdded = isStickerPackAddedToWhatsApp(identifier)
                    result.success(isAdded)
                }
                "addStickerPack" -> {
                    val identifier = call.argument<String>("identifier")
                    val name = call.argument<String>("name")
                    val publisher = call.argument<String>("publisher") ?: "Sticker Studio"
                    val trayImage = call.argument<String>("trayImage") ?: "tray.png"
                    val stickers = call.argument<List<String>>("stickers") ?: emptyList()
                    val animated = call.argument<Boolean>("animated") ?: false

                    if (identifier.isNullOrEmpty() || name.isNullOrEmpty()) {
                        result.error("INVALID_ARGUMENTS", "Identifier and name are required", null)
                        return@setMethodCallHandler
                    }

                    // Save or update metadata file
                    savePackMetadata(identifier, name, publisher, trayImage, stickers, animated)

                    // Launch WhatsApp Intent
                    val intent = Intent()
                    intent.action = "com.whatsapp.intent.action.ENABLE_STICKER_PACK"
                    intent.putExtra("sticker_pack_id", identifier)
                    intent.putExtra("sticker_pack_authority", StickerContentProvider.AUTHORITY)
                    intent.putExtra("sticker_pack_name", name)

                    val isConsumer = isPackageInstalled("com.whatsapp")
                    val isSmb = isPackageInstalled("com.whatsapp.w4b")

                    if (isConsumer) {
                        intent.setPackage("com.whatsapp")
                    } else if (isSmb) {
                        intent.setPackage("com.whatsapp.w4b")
                    } else {
                        result.error("WHATSAPP_NOT_INSTALLED", "WhatsApp is not installed on this device", null)
                        return@setMethodCallHandler
                    }

                    pendingResult = result
                    try {
                        startActivityForResult(intent, ADD_PACK_REQUEST_CODE)
                    } catch (e: ActivityNotFoundException) {
                        pendingResult = null
                        result.error("WHATSAPP_NOT_INSTALLED", "WhatsApp is not installed on this device", null)
                    } catch (e: Exception) {
                        pendingResult = null
                        result.error("ERROR", e.message ?: "Failed to launch WhatsApp", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == ADD_PACK_REQUEST_CODE) {
            val res = pendingResult
            pendingResult = null
            if (res != null) {
                if (resultCode == Activity.RESULT_OK) {
                    res.success(mapOf(
                        "success" to true,
                        "cancelled" to false,
                        "message" to "Sticker pack added to WhatsApp!"
                    ))
                } else {
                    val error = data?.getStringExtra("validation_error")
                    res.success(mapOf(
                        "success" to false,
                        "cancelled" to (resultCode == Activity.RESULT_CANCELED && error == null),
                        "message" to (error ?: "User cancelled adding stickers")
                    ))
                }
            }
        }
    }

    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun isStickerPackAddedToWhatsApp(identifier: String): Boolean {
        val packages = listOf("com.whatsapp", "com.whatsapp.w4b")
        for (pkg in packages) {
            if (isPackageInstalled(pkg)) {
                val authority = "$pkg.provider.sticker_whitelist_check"
                val uri = Uri.Builder()
                    .scheme(ContentResolver.SCHEME_CONTENT)
                    .authority(authority)
                    .appendPath("is_whitelisted")
                    .appendQueryParameter("authority", StickerContentProvider.AUTHORITY)
                    .appendQueryParameter("identifier", identifier)
                    .build()
                try {
                    val cursor: Cursor? = contentResolver.query(uri, null, null, null, null)
                    cursor?.use {
                        if (it.moveToFirst()) {
                            val resultCol = it.getColumnIndex("result")
                            if (resultCol != -1 && it.getInt(resultCol) == 1) {
                                return true
                            }
                        }
                    }
                } catch (ignored: Exception) {
                }
            }
        }
        return false
    }

    private fun savePackMetadata(
        identifier: String,
        name: String,
        publisher: String,
        trayImage: String,
        stickers: List<String>,
        animated: Boolean
    ) {
        val metadataFile = File(filesDir, "stickers_metadata.json")
        val packs = if (metadataFile.exists()) {
            try {
                JSONArray(metadataFile.readText())
            } catch (e: Exception) {
                JSONArray()
            }
        } else {
            JSONArray()
        }

        val newPacks = JSONArray()
        for (i in 0 until packs.length()) {
            val p = packs.getJSONObject(i)
            if (p.optString("identifier") != identifier) {
                newPacks.put(p)
            }
        }

        val packObj = JSONObject().apply {
            put("identifier", identifier)
            put("name", name)
            put("publisher", publisher)
            put("tray_image", trayImage)
            put("stickers", JSONArray(stickers))
            put("animated", animated)
        }
        newPacks.put(packObj)

        metadataFile.writeText(newPacks.toString())
    }
}
