import 'package:ansicolor/ansicolor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;
import 'package:provider/provider.dart';
import 'package:reafy_front/src/provider/auth_provider.dart';
import 'package:reafy_front/src/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

AnsiPen info = AnsiPen()..blue(bold: true);
AnsiPen success = AnsiPen()..green(bold: true);
AnsiPen error = AnsiPen()..red(bold: true);

final baseUrl = dotenv.env['BASE_URL'] ?? 'https://dev.reafy.devkor.club';

class authDio {
  authDio._privateConstructor();
  static final authDio _instance = authDio._privateConstructor();
  factory authDio() {
    return _instance;
  }

  Dio getDio() {
    Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Connection': 'keep-alive',
      },
    ));
/*
    final options = CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.request,
      maxStale: const Duration(days: 1),
      priority: CachePriority.normal,
      cipher: null,
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      allowPostMethod: false,
    );*/

    //dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

    dio.interceptors.clear();
    dio.interceptors.add(CustomLogInterceptor());
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final accessToken = prefs.getString('token');
        options.headers['content-type'] = "application/json";
        options.headers['Authorization'] = 'Bearer $accessToken';
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response != null) {
          if (e.response?.statusCode == 401) {
            final BuildContext? context = Get.context;
            if (context != null) {
              final newToken = await refreshToken();
              if (newToken != null) {
                debugPrint("CLONE REQUESTING");
                e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                final cloneOptions = Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                );
                final cloneResponse = await dio.request(e.requestOptions.path,
                    options: cloneOptions,
                    data: e.requestOptions.data,
                    queryParameters: e.requestOptions.queryParameters);
                return handler.resolve(cloneResponse);
              } else {
                // Refresh token failed, show error dialog and stop further requests
                await showErrorDialog(context, 'Login Expired', '다시 로그인 해주세요.');
                Provider.of<AuthProvider>(context, listen: false)
                    .logout(context);
                //prefs.clear();
                return handler.next(e); //.reject(e);
              }
            }
          } else if (e.response?.statusCode == 500 ||
              e.response?.statusCode == 404) {
            // Show server error dialog
            final BuildContext? context = Get.context;
            if (context != null) {
              await showErrorDialog(context, 'Server Error',
                  '"서버에 문제가 발생했습니다. \n잠시 후 다시 시도해주세요. \n[${e.response?.statusCode.toString() ?? "Unknown Error"}]');
            }
          } else {
            debugPrint(error("[**]Error without response: ${e.response}"));
            debugPrint("[ERROR REQUEST] :${e.requestOptions.data.toString()}");
          }
        }
        return handler.next(e);
      },
    ));
    return dio;
  }

  static Future<String?> refreshToken() async {
    var refreshDio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    refreshDio.interceptors.add(RefreshLogInterceptor());
    try {
      final refreshResponse = await refreshDio.post(
          '${baseUrl}/authentication/refresh',
          options: Options(headers: {
            'content-type': "application/json",
            'Authorization': "Bearer $refreshToken"
          }));

      if (refreshResponse.statusCode == 200 ||
          refreshResponse.statusCode == 201) {
        final newAccessToken = refreshResponse.data['accessToken'];
        await prefs.setString('token', newAccessToken);

        //debugPrint("[********** Refresh Finished ************************]");
        debugPrint("[ END REFRESH ]");
        return newAccessToken;
      } else {
        debugPrint("[ END REFRESH ]");
        return null;
      }
    } catch (e) {
      debugPrint("[ END REFRESH ]");
      //debugPrint(error("[*] Token refresh error: $e"));
      return null;
    }
  }
}

class CustomLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('REQUEST[${options.method}] => ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    debugPrint(
        'RESPONSE[${response.statusCode}] <= ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(error(
        'ERROR[${err.response?.statusCode}] || ${err.requestOptions.path}'));
    //debugPrint(error('ERROR MESSAGE : ${err.message}'));
    super.onError(err, handler);
  }
}

Future<void> showErrorDialog(BuildContext context, String title, String message,
    {Color buttonColor = gray}) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
        title: Center(
          child: Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center),
        ),
        content: Text("$message",
            textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
        contentPadding: const EdgeInsets.all(16),
        actions: [
          Center(
              child: TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(buttonColor),
            ),
            child: Text('확인', style: TextStyle(fontSize: 13, color: white)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
  );
}

void showCircularProgressDialog(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(
        child: SizedBox(
          width: width * 0.1,
          height: width * 0.1,
          child: CircularProgressIndicator.adaptive(
            backgroundColor: green,
            strokeWidth: width * 0.018,
            semanticsLabel: 'Circular Progress Indicator',
          ),
        ),
      );
    },
  );
}
