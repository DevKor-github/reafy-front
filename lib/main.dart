import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:reafy_front/src/binding/init_bindings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:reafy_front/src/controller/connectivity_controller.dart';
import 'package:reafy_front/src/models/bookcount.dart';
import 'package:reafy_front/src/provider/memo_provider.dart';
import 'package:reafy_front/src/provider/stopwatch_provider.dart';
import 'package:reafy_front/src/provider/auth_provider.dart';
import 'package:reafy_front/src/provider/state_book_provider.dart';
import 'package:reafy_front/src/provider/selectedbooks_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:reafy_front/src/pages/splash_screen.dart';
import 'package:reafy_front/src/provider/item_provider.dart';
import 'package:reafy_front/src/provider/item_placement_provider.dart';
import 'package:reafy_front/src/provider/coin_provider.dart';
import 'package:reafy_front/src/provider/time_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:reafy_front/src/utils/constants.dart';
import 'package:showcaseview/showcaseview.dart';

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // env 파일 초기화
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarBrightness: Brightness.light));

  initializeDateFormatting('ko_KR', null);
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<ConnectivityResult>? _networkListener;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (c) => AuthProvider()),
          ChangeNotifierProvider(create: (c) => SelectedBooksProvider()),
          ChangeNotifierProvider(create: (c) => BookShelfProvider()),
          ChangeNotifierProvider(create: (c) => BookModel()),
          ChangeNotifierProvider(create: (c) => ItemProvider()),
          ChangeNotifierProvider(create: (c) => ItemPlacementProvider()),
          ChangeNotifierProvider(create: (c) => StopwatchProvider()),
          ChangeNotifierProvider(create: (c) => CoinProvider()),
          ChangeNotifierProvider(create: (c) => MemoProvider()),
          ChangeNotifierProvider(create: (c) => TimeProvider()),
          ChangeNotifierProvider(
              create: (c) => ConnectivityController()..init()),
        ],
        child: ShowCaseWidget(builder: (context) {
          return GetMaterialApp(
              builder: (context, child) {
                return MediaQuery(
                  child: child!,
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(1.0)),
                );
              },
              title: 'reafy',
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.light,
              theme: new ThemeData(
                scaffoldBackgroundColor: bg_gray,
                primaryColor: yellow,
                colorScheme: ColorScheme(
                    brightness: Brightness.light,
                    primary: yellow,
                    onPrimary: yellow,
                    secondary: yellow_bg,
                    onSecondary: yellow,
                    error: disabled_box,
                    onError: dark_gray,
                    surface: bg_gray,
                    onSurface: black),
                popupMenuTheme: PopupMenuThemeData(color: bg_gray),
                brightness: Brightness.light,
                dialogBackgroundColor: Color(0xffFAF9F7),
                progressIndicatorTheme: ProgressIndicatorThemeData(
                  circularTrackColor: Colors.transparent,
                  color: Colors.transparent,
                ),
                fontFamily: 'NanumSquareRound',
              ),
              initialBinding: InitBinding(),
              home: SplashScreen());
        }));
  }
}
