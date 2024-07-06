import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:reafy_front/src/app.dart';
import 'package:reafy_front/src/components/image_data.dart';
import 'package:reafy_front/src/controller/connectivity_controller.dart';
import 'package:reafy_front/src/pages/intro.dart';
import 'package:reafy_front/src/provider/auth_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:toastification/toastification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_green.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Character(width: size.width, height: size.height),
            SizedBox(height: 10),
            KaKaoLoginButton(
              onTap: () => _KaKaologinbuttonClick(context),
            ),
            Container(
              width: 300,
              child: SignInWithAppleButton(
                onPressed: () => _AppleloginbuttonClick(context),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  void _KaKaologinbuttonClick(BuildContext context) async {
    final connectivityController = context.read<ConnectivityController>();

    if (connectivityController.isConnected) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.loginWithKaKao();

      if (await authProvider.performAuthenticatedAction()) {
        print("isNewUser :${authProvider.isNewUser}");
        Get.off(() => authProvider.isNewUser ? OnBoardingPage() : App());
      } else {
        Get.off(() => LoginPage());
      }
    } else {
      showNetworkErrorSnackbar(context);
    }
  }

  void _AppleloginbuttonClick(BuildContext context) async {
    final connectivityController = context.read<ConnectivityController>();

    if (connectivityController.isConnected) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.loginWithApple();

      if (await authProvider.performAuthenticatedAction()) {
        Get.off(() => authProvider.isNewUser ? OnBoardingPage() : App());
      } else {
        Get.off(() => LoginPage());
      }
    } else {
      showNetworkErrorSnackbar(context);
      //Get.off(() => LoginPage());
    }
  }
}

class KaKaoLoginButton extends StatelessWidget {
  final VoidCallback onTap;
  const KaKaoLoginButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: ImageData(
          IconsPath.login_button,
          isSvg: false,
          width: 300,
          height: 70,
        ),
      ),
    );
  }
}

class Character extends StatelessWidget {
  final double width;
  final double height;

  const Character({Key? key, required this.width, required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: width,
          height: height * 0.6,
          decoration: BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.center,
              image: AssetImage(IconsPath.login_character),
              fit: BoxFit.fitWidth,
            ),
          ),
        ));
  }
}

void showNetworkErrorSnackbar(BuildContext context) {
  toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.flatColored,
      title: Text('네트워크 연결 상태를 확인해주세요.'),
      autoCloseDuration: const Duration(seconds: 2),
      showProgressBar: false);
}
