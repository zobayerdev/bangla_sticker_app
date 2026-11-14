import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sticker_flutter/assets_helper/app_colors.dart';
import 'package:sticker_flutter/common_widgets/custom_toast.dart';
import 'package:sticker_flutter/features/home_screen/model/pack_model.dart';
import 'package:sticker_flutter/helpers/ui_helpers.dart';

final class WhatsAppStickerService {
  WhatsAppStickerService._();

  static const MethodChannel _channel =
      MethodChannel('com.example.sticker_flutter/whatsapp');

  static Future<bool> isWhatsAppInstalled() async {
    try {
      final bool? result = await _channel.invokeMethod('isWhatsAppInstalled');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isPackAdded(String identifier) async {
    try {
      final bool? result = await _channel.invokeMethod('isPackAdded', {
        'identifier': identifier,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> addPackToWhatsApp(
    BuildContext context,
    PackModel pack,
  ) async {
    final identifier = pack.identifier;
    final name = pack.name;
    final trayIconUrl = pack.trayIcon;
    final stickers = pack.stickers ?? [];

    if (identifier == null || name == null || trayIconUrl == null) {
      customToastMessage('Error', 'Invalid sticker pack data.');
      return;
    }

    if (stickers.length < 3) {
      customToastMessage(
        'Warning',
        'WhatsApp requires at least 3 stickers in a pack.',
      );
      return;
    }

    final hasWhatsApp = await isWhatsAppInstalled();
    if (!hasWhatsApp) {
      customToastMessage(
        'WhatsApp',
        'WhatsApp or WhatsApp Business is not installed.',
      );
      return;
    }

    // Show progress dialog
    final ValueNotifier<String> progressStatus = ValueNotifier(
      "Preparing sticker pack...",
    );

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: const Color(0xFF1E2235),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 44.r,
                    height: 44.r,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  ),
                  UIHelper.verticalSpace(18.h),
                  ValueListenableBuilder<String>(
                    valueListenable: progressStatus,
                    builder: (context, status, _) {
                      return Text(
                        status,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final String stickersRoot = await _channel.invokeMethod(
        'getStickersDir',
      );
      final packDir = Directory('$stickersRoot/$identifier');
      if (!await packDir.exists()) {
        await packDir.create(recursive: true);
      }

      final dio = Dio();

      // 1. Download tray icon
      progressStatus.value = "Downloading tray icon...";
      final trayFile = File('${packDir.path}/tray.png');
      if (!await trayFile.exists()) {
        final response = await dio.get<List<int>>(
          trayIconUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        if (response.data != null) {
          await trayFile.writeAsBytes(response.data!);
        }
      }

      // 2. Download each sticker
      final List<String> stickerFileNames = [];
      for (int i = 0; i < stickers.length; i++) {
        progressStatus.value =
            "Downloading stickers (${i + 1}/${stickers.length})...";
        final stickerUrl = stickers[i];
        final fileName = 'sticker_$i.webp';
        final stickerFile = File('${packDir.path}/$fileName');

        if (!await stickerFile.exists()) {
          final response = await dio.get<List<int>>(
            stickerUrl,
            options: Options(responseType: ResponseType.bytes),
          );
          if (response.data != null) {
            await stickerFile.writeAsBytes(response.data!);
          }
        }
        stickerFileNames.add(fileName);
      }

      progressStatus.value = "Opening WhatsApp...";

      final dynamic rawResult = await _channel.invokeMethod('addStickerPack', {
        'identifier': identifier,
        'name': name,
        'publisher': 'Sticker Studio',
        'trayImage': 'tray.png',
        'stickers': stickerFileNames,
        'animated': false,
      });

      // Dismiss dialog
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (rawResult is Map) {
        final success = rawResult['success'] == true;
        final cancelled = rawResult['cancelled'] == true;
        final message = rawResult['message']?.toString();

        if (success) {
          customToastMessage('WhatsApp', 'Successfully added "$name" to WhatsApp!');
        } else if (cancelled) {
          customToastMessage('Cancelled', 'Sticker pack was not added.');
        } else {
          customToastMessage('Error', message ?? 'Could not add stickers to WhatsApp.');
        }
      }
    } catch (e) {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      customToastMessage('Error', 'Failed to prepare stickers: $e');
    }
  }
}
