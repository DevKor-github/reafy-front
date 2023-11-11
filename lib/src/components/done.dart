import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reafy_front/src/components/image_data.dart';
import 'package:reafy_front/src/pages/book/bookshelf.dart';

class DoneDialog extends StatefulWidget {
  @override
  _DoneDialogState createState() => _DoneDialogState();
}

class _DoneDialogState extends State<DoneDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.zero,
      //title:
      content: Container(
        width: 248,
        height: 210,
        child: ImageData(
          IconsPath.done,
          isSvg: true,
        ),
      ),
      actions: <Widget>[],
    );
  }
}
/////
