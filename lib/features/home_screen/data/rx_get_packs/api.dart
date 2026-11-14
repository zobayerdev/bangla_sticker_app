import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../networks/dio/dio.dart';
import '../../../../networks/endpoints.dart';
import '../../../../networks/exception_handler/data_source.dart';

final class GetPacksApi {
  static final GetPacksApi _singleton = GetPacksApi._internal();
  GetPacksApi._internal();
  static GetPacksApi get instance => _singleton;

  Future<Map> getPacks() async {
    try {
      Response response = await getHttp(Endpoints.getPacks());
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map data = json.decode(json.encode(response.data));
        return data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }
}
