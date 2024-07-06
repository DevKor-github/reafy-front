import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reafy_front/src/components/image_data.dart';
import 'package:reafy_front/src/pages/book/category_bookshelf.dart';
import 'package:reafy_front/src/provider/state_book_provider.dart';
import 'package:provider/provider.dart';

class State_BookShelfWidget extends StatefulWidget {
  final String title;
  final int state;

  const State_BookShelfWidget(
      {required this.title, required this.state, Key? key})
      : super(key: key);

  @override
  State<State_BookShelfWidget> createState() => State_BookShelfWidgetState();
}

class State_BookShelfWidgetState extends State<State_BookShelfWidget> {
  @override
  void initState() {
    super.initState();
    Provider.of<BookShelfProvider>(context, listen: false).fetchData();
  }

  List<Widget> _buildBookList(BuildContext context) {
    List<String> thumbnailList = [];

    if (widget.state == 1) {
      thumbnailList =
          Provider.of<BookShelfProvider>(context).thumbnailsForProgressState1;
    } else if (widget.state == 2) {
      thumbnailList =
          Provider.of<BookShelfProvider>(context).thumbnailsForProgressState2;
    } else {
      thumbnailList = [];
    }

    return thumbnailList.map((thumbnail) {
      return Padding(
        padding: const EdgeInsets.only(right: 18.61),
        child: Container(
          width: 68,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Color(0xffffffff),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              thumbnail,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // 이미지를 불러오는 데 실패한 경우의 처리
                return const Text('이미지를 불러올 수 없습니다.');
              },
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<String> thumbnailList;

    if (widget.state == 1) {
      thumbnailList =
          Provider.of<BookShelfProvider>(context).thumbnailsForProgressState1;
    } else if (widget.state == 2) {
      thumbnailList =
          Provider.of<BookShelfProvider>(context).thumbnailsForProgressState2;
    } else {
      thumbnailList = [];
    }

    return GestureDetector(
        onTap: () {
          Get.to(Category_BookShelf(
            pageTitle: widget.title,
          ));
        },
        child: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff333333),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        thumbnailList.length.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff333333),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 7),
                      Container(
                        width: 10,
                        height: 19,
                        child: ImageData(IconsPath.shelf_right, isSvg: true),
                      ),
                      SizedBox(width: 24),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                width: double.maxFinite,
                height: 140,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/shelf.png'),
                      alignment: Alignment.bottomCenter,
                      fit: BoxFit.fitWidth),
                ),
                child: Column(
                  children: [
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          SizedBox(
                            width: 26,
                          ),
                          Row(
                            children: _buildBookList(context),
                          ),
                          SizedBox(
                            width: 26,
                          ),
                        ])),
                  ],
                ),
              ),
              SizedBox(height: 15),
            ])));
  }
}
