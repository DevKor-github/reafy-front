import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:reafy_front/src/components/book_memo.dart';
import 'package:reafy_front/src/components/image_data.dart';
import 'package:reafy_front/src/components/delete_book.dart';
import 'package:reafy_front/src/components/modify_book.dart';
import 'package:reafy_front/src/components/new_book_memo.dart';
import 'package:reafy_front/src/pages/board.dart';
import 'package:reafy_front/src/provider/state_book_provider.dart';
import 'package:reafy_front/src/repository/bookshelf_repository.dart';
import 'package:reafy_front/src/repository/history_repository.dart';
import 'package:reafy_front/src/utils/reading_progress.dart';

class BookDetailPage extends StatefulWidget {
  final int bookshelfBookId;

  const BookDetailPage({Key? key, required this.bookshelfBookId})
      : super(key: key);

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Future<BookshelfBookDetailsDto> bookDetailsFuture;
  bool isFavorite = false;
  int totalPagesRead = 0;

  @override
  void initState() {
    super.initState();
    bookDetailsFuture = getBookshelfBookDetails(widget.bookshelfBookId);
    bookDetailsFuture.then((bookDetails) {
      setState(() {
        isFavorite = bookDetails.isFavorite == 1 ? true : false;
      });
    }).catchError((error) {
      print('Error fetching book details: $error');
    });

    CalculateTotalPagesRead();
  }

  void CalculateTotalPagesRead() async {
    try {
      List<dynamic> historyList =
          await getBookshelfBookHistory(widget.bookshelfBookId);
      int readPages = calculateTotalPagesRead(historyList);
      setState(() {
        totalPagesRead = readPages;
      });
    } catch (e) {
      print('Error fetching book history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            iconSize: 44,
            padding: EdgeInsets.all(0),
            icon: ImageData(IconsPath.pencil_green, isSvg: true),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ModifyDialog(bookId: widget.bookshelfBookId);
                },
              );
            },
          ),
          IconButton(
            iconSize: 44,
            padding: EdgeInsets.only(right: 10),
            icon: ImageData(IconsPath.trash_can, isSvg: true),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DeleteDialog(bookId: widget.bookshelfBookId);
                },
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true, //appbar, body 겹치기

      body: FutureBuilder<BookshelfBookDetailsDto>(
          future: bookDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('에러: ${snapshot.error}');
            } else {
              final BookshelfBookDetailsDto bookDetails = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: <Widget>[
                        Container(
                          width: size.width,
                          height: 397, //442
                          color: Color(0xfffff7da),
                        ),
                        Positioned(
                          top: 310,
                          child: HillImage(width: size.width),
                        ),
                        Positioned(
                          top: 116,
                          left: 28,
                          child: LeafImage(),
                        ),
                        Positioned(
                          top: 107,
                          left: (size.width - 178) / 2,
                          child: BookImage(bookDetails: bookDetails),
                        ),
                        Positioned(
                          top: 220,
                          left: size.width / 2 + 35,
                          child: PoobaoImage(),
                        ),
                      ],
                    ),
                    //SizedBox(height: 18.0),
                    IconButton(
                      padding: EdgeInsets.only(left: 26),
                      icon: isFavorite
                          ? ImageData(IconsPath.favorite,
                              isSvg: true, width: 22, height: 22)
                          : ImageData(IconsPath.nonFavorite,
                              isSvg: true, width: 22, height: 22),
                      onPressed: () async {
                        try {
                          await updateBookshelfBookFavorite(
                              bookDetails.bookshelfBookId);
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                          Provider.of<BookShelfProvider>(context, listen: false)
                              .fetchData();
                        } catch (e) {
                          print('에러 발생: $e');
                        }
                      },
                    ),
                    _book_info(bookDetails),
                    SizedBox(height: 27.0),
                    ProgressIndicator(
                        totalPages: bookDetails.pages,
                        pagesRead: totalPagesRead),
                    SizedBox(height: 21.0),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 26),
                      child: Text(
                        "메모",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff333333),
                        ),
                      ),
                    ),
                    SizedBox(height: 11),
                    MemoSection(bookshelfBookId: widget.bookshelfBookId),
                    SizedBox(height: 9.0),
                    //AddMemoButton(bookshelfBookId: widget.bookshelfBookId),
                    SizedBox(height: 17.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: EdgeInsets.only(right: 23),
                        child: Text(
                          "도서 DB 제공: 알라딘",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w400,
                            color: Color(0xffb3b3b3),
                          ),
                        ),
                      ),
                    ),
                    Spacer()
                  ],
                ),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddBookMemoBottomSheet(context, widget.bookshelfBookId);
        },
        //backgroundColor: Color(0xffB3B3B3),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 26),
          width: 333,
          height: 33,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xffB3B3B3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat, // 버튼 위치 조정
    );
  }

  Widget _book_info(BookshelfBookDetailsDto bookDetails) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (bookDetails.title.length ?? 0) > 20
                ? '${bookDetails.title.substring(0, 20)}\n${bookDetails.title.substring(
                    21,
                  )}'
                : '${bookDetails.title ?? ''}',
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xff333333),
            ),
          ),
          SizedBox(height: 11),
          Row(
            children: [
              Text(
                "저자",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff333333),
                ),
              ),
              SizedBox(width: 5),
              Text(
                (bookDetails.author.length ?? 0) > 26
                    ? '${bookDetails.author.substring(0, 26)}\n${bookDetails.author.substring(
                        26,
                      )}'
                    : '${bookDetails.author ?? ''}',
                overflow: TextOverflow.clip, // 길이 초과 시 '...'로 표시
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff333333),
                ),
              ),
            ],
          ),
          SizedBox(height: 7),
          Row(
            children: [
              Text(
                "출판사",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff333333),
                ),
              ),
              SizedBox(width: 5),
              Text(
                (bookDetails.publisher.length ?? 0) > 25
                    ? '${bookDetails.publisher.substring(0, 25)}\n${bookDetails.publisher.substring(
                        25,
                      )}'
                    : '${bookDetails.publisher ?? ''}',
                overflow: TextOverflow.clip, // 길이 초과 시 '...'로 표시
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff333333),
                ),
              ),
            ],
          ),
          SizedBox(height: 7),
          Row(
            children: [
              Text(
                "카테고리",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff333333),
                ),
              ),
              SizedBox(width: 5),
              Text(
                (bookDetails.category.length ?? 0) > 25
                    ? '${bookDetails.category.substring(0, 25)}\n${bookDetails.category.substring(
                        25,
                      )}'
                    : '${bookDetails.category ?? ''}',
                overflow: TextOverflow.clip, // 길이 초과 시 '...'로 표시
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff333333),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/////////////////////////////////////////////

class BookImage extends StatelessWidget {
  final BookshelfBookDetailsDto bookDetails;

  const BookImage({Key? key, required this.bookDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 178,
      height: 259,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(2.0, 4.0),
            blurRadius: 3.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: bookDetails.thumbnailURL != null
            ? Image.network(
                bookDetails.thumbnailURL,
                fit: BoxFit.cover,
              )
            : Placeholder(),
      ),
    );
  }
}

class LeafImage extends StatelessWidget {
  const LeafImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 332.36,
      height: 181.455,
      child: ImageData(IconsPath.book_leaves),
    );
  }
}

class HillImage extends StatelessWidget {
  final double width;

  const HillImage({Key? key, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 90,
      child: ImageData(IconsPath.hill),
    );
  }
}

class PoobaoImage extends StatelessWidget {
  const PoobaoImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 103,
      height: 144,
      child: ImageData(IconsPath.character),
    );
  }
}

class ProgressIndicator extends StatelessWidget {
  final int totalPages;
  final int pagesRead;

  const ProgressIndicator({
    Key? key,
    required this.totalPages,
    required this.pagesRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progressPercent =
        totalPages > 0 ? (pagesRead / totalPages * 100).clamp(0, 100) : 0;
    String progressImagePath = getProgressImage(progressPercent);

    return Container(
      padding: EdgeInsets.only(left: 23.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "진행 정도",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff333333),
                ),
              ),
              SizedBox(width: 266.0),
              Text(
                "${progressPercent.toStringAsFixed(0)}%",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff333333),
                ),
              ), //변경
            ],
          ),
          Container(
            width: 344,
            height: 46,
            child: ImageData(progressImagePath),
          ),
        ],
      ),
    );
  }
}

class AddMemoButton extends StatelessWidget {
  final int bookshelfBookId;

  const AddMemoButton({
    Key? key,
    required this.bookshelfBookId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showAddBookMemoBottomSheet(context, bookshelfBookId);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 26),
        width: 343,
        height: 33,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xffB3B3B3),
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
