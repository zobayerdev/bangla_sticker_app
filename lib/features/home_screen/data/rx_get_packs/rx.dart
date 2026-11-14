import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../common_widgets/custom_toast.dart';
import '../../../../networks/rx_base.dart';
import 'api.dart';

final class GetPacksRx extends RxResponseInt {
  final api = GetPacksApi.instance;

  String message = "Something went wrong";

  GetPacksRx({required super.empty, required super.dataFetcher});

  ValueStream get fillData => dataFetcher.stream;

  Future<bool> fetchPacks() async {
    try {
      Map resdata = await api.getPacks();
      return await handleSuccessWithReturn(resdata);
    } catch (error) {
      return await handleErrorWithReturn(error);
    }
  }

  @override
  handleSuccessWithReturn(data) async {
    dataFetcher.sink.add(data);
    return true;
  }

  @override
  handleErrorWithReturn(error) {
    String message = 'Something went wrong';
    log(error.toString());
    if (error is DioException) {
      message =
          error.response?.data["message"]?.toString() ?? "Something went wrong";
      if (error.type == DioExceptionType.connectionError) {
        message = "Check Your Network Connection";
      }
    }
    customToastMessage('Error', message);
    return false;
  }
}
