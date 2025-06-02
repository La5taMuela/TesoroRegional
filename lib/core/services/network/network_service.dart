import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

abstract class NetworkService {
  Future<bool> get isConnected;
  Dio get dio;
}

class NetworkServiceImpl implements NetworkService {
  final Dio _dio = Dio();
  final logger;

  NetworkServiceImpl({required this.logger}) {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  @override
  Dio get dio => _dio;

  @override
  Future<bool> get isConnected async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }
}
