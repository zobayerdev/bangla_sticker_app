package com.example.sticker_flutter

import android.content.ContentProvider
import android.content.ContentValues
import android.content.UriMatcher
import android.content.res.AssetFileDescriptor
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

class StickerContentProvider : ContentProvider() {

    companion object {
        const val AUTHORITY = "com.example.sticker_flutter.stickercontentprovider"
        private const val METADATA = 1
        private const val METADATA_PACK = 2
        private const val STICKERS = 3
        private const val STICKERS_ASSET = 4

        private val MATCHER = UriMatcher(UriMatcher.NO_MATCH).apply {
            addURI(AUTHORITY, "metadata", METADATA)
            addURI(AUTHORITY, "metadata/*", METADATA_PACK)
            addURI(AUTHORITY, "stickers/*", STICKERS)
            addURI(AUTHORITY, "stickers_asset/*/*", STICKERS_ASSET)
        }
    }

    override fun onCreate(): Boolean = true

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?
    ): Cursor? {
        val context = context ?: return null
        val metadataFile = File(context.filesDir, "stickers_metadata.json")
        val packs = if (metadataFile.exists()) {
            try {
                JSONArray(metadataFile.readText())
            } catch (e: Exception) {
                JSONArray()
            }
        } else {
            JSONArray()
        }

        return when (MATCHER.match(uri)) {
            METADATA -> {
                val cursor = MatrixCursor(arrayOf(
                    "sticker_pack_identifier",
                    "sticker_pack_name",
                    "sticker_pack_publisher",
                    "sticker_pack_icon",
                    "android_play_store_link",
                    "ios_app_download_link",
                    "sticker_pack_publisher_email",
                    "sticker_pack_publisher_website",
                    "sticker_pack_privacy_policy_website",
                    "sticker_pack_license_agreement_website",
                    "image_data_version",
                    "whatsapp_will_not_cache_stickers",
                    "animated_sticker_pack"
                ))
                for (i in 0 until packs.length()) {
                    val pack = packs.getJSONObject(i)
                    cursor.addRow(arrayOf(
                        pack.optString("identifier"),
                        pack.optString("name"),
                        pack.optString("publisher", "Sticker Studio"),
                        pack.optString("tray_image", "tray.png"),
                        "",
                        "",
                        "",
                        "",
                        "",
                        "",
                        "1",
                        0,
                        if (pack.optBoolean("animated", false)) 1 else 0
                    ))
                }
                cursor.setNotificationUri(context.contentResolver, uri)
                cursor
            }
            METADATA_PACK -> {
                val identifier = uri.lastPathSegment ?: return null
                val cursor = MatrixCursor(arrayOf(
                    "sticker_pack_identifier",
                    "sticker_pack_name",
                    "sticker_pack_publisher",
                    "sticker_pack_icon",
                    "android_play_store_link",
                    "ios_app_download_link",
                    "sticker_pack_publisher_email",
                    "sticker_pack_publisher_website",
                    "sticker_pack_privacy_policy_website",
                    "sticker_pack_license_agreement_website",
                    "image_data_version",
                    "whatsapp_will_not_cache_stickers",
                    "animated_sticker_pack"
                ))
                for (i in 0 until packs.length()) {
                    val pack = packs.getJSONObject(i)
                    if (pack.optString("identifier") == identifier) {
                        cursor.addRow(arrayOf(
                            pack.optString("identifier"),
                            pack.optString("name"),
                            pack.optString("publisher", "Sticker Studio"),
                            pack.optString("tray_image", "tray.png"),
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            "1",
                            0,
                            if (pack.optBoolean("animated", false)) 1 else 0
                        ))
                        break
                    }
                }
                cursor.setNotificationUri(context.contentResolver, uri)
                cursor
            }
            STICKERS -> {
                val identifier = uri.lastPathSegment ?: return null
                val cursor = MatrixCursor(arrayOf(
                    "sticker_file_name",
                    "sticker_emoji",
                    "sticker_accessibility_text"
                ))
                for (i in 0 until packs.length()) {
                    val pack = packs.getJSONObject(i)
                    if (pack.optString("identifier") == identifier) {
                        val stickers = pack.optJSONArray("stickers") ?: JSONArray()
                        for (s in 0 until stickers.length()) {
                            val stickerObj = stickers.opt(s)
                            val fileName = if (stickerObj is JSONObject) {
                                stickerObj.optString("file_name")
                            } else {
                                stickerObj.toString()
                            }
                            cursor.addRow(arrayOf(fileName, "😊,❤️", pack.optString("name")))
                        }
                        break
                    }
                }
                cursor.setNotificationUri(context.contentResolver, uri)
                cursor
            }
            else -> null
        }
    }

    override fun getType(uri: Uri): String? {
        return when (MATCHER.match(uri)) {
            METADATA -> "vnd.android.cursor.dir/vnd.$AUTHORITY.metadata"
            METADATA_PACK -> "vnd.android.cursor.item/vnd.$AUTHORITY.metadata"
            STICKERS -> "vnd.android.cursor.dir/vnd.$AUTHORITY.stickers"
            STICKERS_ASSET -> {
                val path = uri.path ?: ""
                if (path.endsWith(".png")) "image/png" else "image/webp"
            }
            else -> null
        }
    }

    override fun openAssetFile(uri: Uri, mode: String): AssetFileDescriptor? {
        val context = context ?: return null
        val match = MATCHER.match(uri)
        if (match == STICKERS_ASSET) {
            val segments = uri.pathSegments
            if (segments.size >= 3) {
                val identifier = segments[segments.size - 2]
                val fileName = segments[segments.size - 1]
                val file = File(context.filesDir, "stickers/$identifier/$fileName")
                if (file.exists()) {
                    val pfd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
                    return AssetFileDescriptor(pfd, 0, AssetFileDescriptor.UNKNOWN_LENGTH)
                }
            }
        }
        return null
    }

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null
    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0
    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<out String>?): Int = 0
}
