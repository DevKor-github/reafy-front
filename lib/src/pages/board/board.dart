import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reafy_front/src/components/image_data.dart';
import 'package:reafy_front/src/components/memo_card.dart';
import 'package:reafy_front/src/controller/board_controller.dart';
import 'package:reafy_front/src/pages/board/newmemo.dart';
import 'package:reafy_front/src/repository/memo_repository.dart';
import 'package:reafy_front/src/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Board extends GetView<BoardController> {
  const Board({super.key});

  Widget _memoList() {
    return Obx(() => Column(
          children: List.generate(controller.memoList.length,
              (index) => MemoCard(memo: controller.memoList[index])).toList(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => BoardController());
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Color(0xff63B865)),
            onPressed: () {
              Get.back(); // Navigator.pop 대신 Get.back()을 사용합니다.
            },
          ),
          title: Text(
            "나의 메모",
            style: TextStyle(
                color: Color(0xff333333),
                fontWeight: FontWeight.w800,
                fontSize: 16),
          ),
          actions: [],
        ),
        extendBodyBehindAppBar: true,
        floatingActionButton: NewMemoButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/green_bg.png'),
                fit: BoxFit.fill,
              ),
            ),
            width: size.width,
            height: size.height,
            child: ListView(
              children: [_memoList()],
            )));
  }
}

class NewMemoButton extends StatelessWidget {
  const NewMemoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showAddMemoBottomSheet(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 26),
        width: 343,
        height: 33,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: yellow,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 20,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          child: ImageData(
            IconsPath.add_memo,
            isSvg: true,
          ),
        ),
      ),
    );
  }
}
