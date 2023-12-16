import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:reafy_front/src/app.dart';
import 'package:reafy_front/src/binding/init_bindings.dart';
import 'package:reafy_front/src/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'package:reafy_front/src/components/poobao_home.dart';
import 'package:reafy_front/src/models/bookCount.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:reafy_front/src/provider/stopwatch_provider.dart';
import 'package:reafy_front/src/provider/auth_provider.dart';
import 'package:reafy_front/src/provider/state_book_provider.dart';
import 'package:reafy_front/src/provider/bamboo_provider.dart';
import 'package:reafy_front/src/provider/selectedbooks_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:reafy_front/src/root.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // env 파일 초기화
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  initializeDateFormatting('ko_KR', null);
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']);

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (c) => AuthProvider()),
          ChangeNotifierProvider(create: (c) => SelectedBooksProvider()),
          ChangeNotifierProvider(create: (c) => BookShelfProvider()),
          ChangeNotifierProvider(create: (c) => BookModel()),
          ChangeNotifierProvider(create: (c) => PoobaoHome()),
/*
          ChangeNotifierProvider(create: (_) => GiftProvider()),
          ChangeNotifierProxyProvider<GiftProvider, StopwatchProvider>(
            create: (_) => StopwatchProvider(),
            update: (_, giftProvider, stopwatchProvider) =>
                stopwatchProvider!..giftProvider = giftProvider,
          ),*/

          ChangeNotifierProvider(create: (c) => StopwatchProvider()),
          ChangeNotifierProvider(create: (c) => BambooProvider()),
        ],
        child: GetMaterialApp(
            builder: (context, child) {
              return MediaQuery(
                child: child!,
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              );
            },
            title: 'reafy',
            debugShowCheckedModeBanner: false,
            theme: new ThemeData(
              fontFamily: 'NanumSquareRound',
            ),
            initialBinding: InitBinding(),
            home: Root()));
  }
}














  /*
  void _autoLoginCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null) {
      setState(() {
        isToken = true;
      });
    }
  }

  bool isToken = false;
  _autoLoginCheck();*/








  
  //runApp(
  /*
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => SelectedBooksProvider()),
        ChangeNotifierProvider(create: (ctx) => BookShelfProvider()),
        ChangeNotifierProvider(create: (ctx) => BookModel()),
        ChangeNotifierProvider(create: (ctx) => PoobaoHome()),
        ChangeNotifierProvider(create: (ctx) => StopwatchProvider()),
      ],
      child: */
  //    MyApp());

/*
  initializeDateFormatting().then((_) => runApp(
      ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(), child: MyApp())));*/