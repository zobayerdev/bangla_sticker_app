import 'dart:developer';
import 'package:sticker_flutter/constants/app_constants.dart';
import 'package:sticker_flutter/helpers/di.dart';
import 'package:sticker_flutter/networks/dio/dio.dart';

Future<void> performPostLoginActions() async {
  try {
    final token = appData.read(kKeyAccessToken);
    if (token != null && token.toString().isNotEmpty) {
      DioSingleton.instance.update(token.toString());
      log("Dio configured with authenticated bearer token.");
    }
  } catch (e) {
    log("Error during performPostLoginActions: $e");
  }
}
