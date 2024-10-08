import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reafy_front/src/components/image_data.dart';
import 'package:reafy_front/src/pages/book/favorite_bookshelf.dart';
import 'package:get/get.dart';
import 'package:reafy_front/src/provider/state_book_provider.dart';

class isFavorite_BookShelfWidget extends StatefulWidget {
  final String title;

  const isFavorite_BookShelfWidget({required this.title, Key? key})
      : super(key: key);

  @override
  State<isFavorite_BookShelfWidget> createState() =>
      isFavorite_BookShelfWidgetState();
}

class isFavorite_BookShelfWidgetState
    extends State<isFavorite_BookShelfWidget> {
  @override
  void initState() {
    super.initState();
    Provider.of<BookShelfProvider>(context, listen: false)
        .fetchFavoriteThumbnailList();
  }

  List<Widget> _buildBookList(BuildContext context) {
    List<String> thumbnailList =
        Provider.of<BookShelfProvider>(context).thumbnailsForIsFavorite;

    return thumbnailList.map((thumbnail) {
      return Padding(
        padding: const EdgeInsets.only(right: 21.61, top: 7),
        child: Container(
          width: 66,
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
    List<String> thumbnailList =
        Provider.of<BookShelfProvider>(context).thumbnailsForIsFavorite;

    return GestureDetector(
        onTap: () {
          Get.to(Favorite_BookShelf(
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
