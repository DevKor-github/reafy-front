import 'package:flutter/material.dart';
import 'package:reafy_front/src/components/image_data.dart';
import 'package:reafy_front/src/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileName extends StatefulWidget {
  @override
  _ProfileNameState createState() => _ProfileNameState();
}

class _ProfileNameState extends State<ProfileName> {
  String _displayText = "";

  Future<void> setNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nickname = prefs.getString('nickname');

    setState(() {
      if (nickname != null) {
        _displayText = nickname;
      } else {
        _displayText = "Reafy";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setNickname();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              width: SizeConfig.screenWidth,
              height: 166,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff64c567),
                    Color(0xffb6e0b7),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                  top: 92.0,
                  left: (SizeConfig.screenWidth - 153) / 2.0,
                  bottom: 21.53),
              width: 153.47,
              height: 153.47,
              decoration: BoxDecoration(
                color: Color(0xffffffff),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xfffcfcfc),
                  width: 5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    spreadRadius: 3.0,
                    blurRadius: 7.0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  width: 148.47,
                  height: 148.47,
                  decoration: BoxDecoration(
                    color: Color(0xffe2eee0),

                    //image: DecorationImage(image:  )
                  ),
                  child: FittedBox(
                    child: ImageData(IconsPath.profile),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ],
        ),
        Center(
          child: Text(
            _displayText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xff000000),
            ),
          ),
        ),
      ],
    );
  }
}
