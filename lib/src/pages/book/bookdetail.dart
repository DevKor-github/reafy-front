import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:reafy_front/src/components/book_memo.dart';
import 'package:reafy_front/src/components/image_data.dart';
import 'package:reafy_front/src/components/delete_book.dart';
import 'package:reafy_front/src/components/modify_book.dart';
import 'package:reafy_front/src/components/new_book_memo.dart';
import 'package:reafy_front/src/pages/book/bookhistory.dart';
import 'package:reafy_front/src/provider/state_book_provider.dart';
import 'package:reafy_front/src/repository/bookshelf_repository.dart';
import 'package:reafy_front/src/repository/history_repository.dart';
import 'package:reafy_front/src/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

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
  int currentPage = 1;
  dynamic recentHistory;

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
      dynamic tmpRecentHistory =
          await getBookshelfBookRecentHistory(widget.bookshelfBookId);
      setState(() {
        recentHistory = tmpRecentHistory!;
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
        backgroundColor: yellow_bg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: green),
          onPressed: () {
            Provider.of<BookShelfProvider>(context, listen: false).fetchData();
            Get.back();
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
              return Center(
                  child: CircularProgressIndicator(color: Colors.transparent));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final BookshelfBookDetailsDto bookDetails = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: <Widget>[
                        Container(
                          width: SizeConfig.screenWidth,
                          height: 397, //442
                          color: Color(0xfffff7da),
                        ),
                        Positioned(
                          top: 310,
                          child: HillImage(width: SizeConfig.screenWidth),
                        ),
                        Positioned(
                          top: 116,
                          left: (SizeConfig.screenWidth - 332) / 2, //28,
                          child: LeafImage(),
                        ),
                        Positioned(
                          top: 107,
                          left: (SizeConfig.screenWidth - 178) / 2,
                          child: BookImage(bookDetails: bookDetails),
                        ),
                        Positioned(
                          bottom: 10, //: 220,
                          left: SizeConfig.screenWidth / 2 + 35,
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
                      pagesRead: bookDetails.totalPagesRead,
                      recentHistory: recentHistory,
                    ),
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
                    // //AddMemoButton(bookshelfBookId: widget.bookshelfBookId),
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
                    SizedBox(height: 50),
                    //Spacer()
                  ],
                ),
              );
            }
          }),
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Get.to(
                    () => BookHistory(bookshelfBookId: widget.bookshelfBookId));
              },
              child: Container(
                width: 33,
                height: 33,
                decoration: BoxDecoration(
                  color: Color(0xff63B865),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Padding(
                    padding: EdgeInsets.all(4.5),
                    child: ImageData(
                      IconsPath.historyButton,
                      isSvg: true,
                    )),
              ),
            ),
            SizedBox(width: 10),
            Container(
              width: size.width - 90,
              height: 33,
              decoration: BoxDecoration(
                color: Color(0xffB3B3B3),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  showAddBookMemoBottomSheet(context, widget.bookshelfBookId);
                },
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // Making the FAB rectangular
                ),
                backgroundColor:
                    Colors.transparent, // Making FAB's background transparent
                elevation: 0, // Removing any additional shadow or elevation
                child: Icon(Icons.add, color: Colors.white), // Button icon
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _book_info(BookshelfBookDetailsDto bookDetails) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bookDetails.title,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xff333333),
            ),
            maxLines: null,
            softWrap: true,
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
                bookDetails.author,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff333333),
                ),
                maxLines: null,
                softWrap: true,
              )
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
                bookDetails.publisher,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff333333),
                ),
                maxLines: null,
                softWrap: true,
              )
            ],
          ),
          SizedBox(height: 7),
          hyperlinkText(bookDetails.link),
        ],
      ),
    );
  }

  Widget hyperlinkText(String? url) {
    return InkWell(
      onTap: () async {
        if (url != null && await canLaunch(url)) {
          await launch(url);
        } else {
          print('Could not launch $url');
        }
      },
      child: Text(
        "책 상세보기",
        overflow: TextOverflow.clip,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xff333333),
          decoration: TextDecoration.underline,
        ),
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
        borderRadius: BorderRadius.circular(10.0),
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
      width: SizeConfig.screenWidth,
      height: 90,
      child: Image.asset(
        IconsPath.hill,
        width: SizeConfig.screenWidth,
        height: 90,
        fit: BoxFit.fill, // Ensure the image fills the available space
      ),
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
  final dynamic recentHistory;

  const ProgressIndicator({
    Key? key,
    required this.totalPages,
    required this.pagesRead,
    this.recentHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progressPercent =
        totalPages > 0 ? (pagesRead / totalPages * 100).clamp(0, 100) : 0;

    double balloonLeftPosition(double progressPercent) {
      int filledBars = (progressPercent / 10).floor();
      return filledBars * (30 + 4) - 20;
    }

    int calculateLeftOffset(int pagesRead) {
      int digits = pagesRead.toString().length;

      if (digits == 1) {
        return 40;
      } else if (digits == 2) {
        return 36;
      } else if (digits == 3) {
        return 33;
      } else {
        return 30;
      }
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 26),
                child: Text(
                  "진행 정도",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff333333),
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(
                  right: 26,
                ),
                child: Text(
                  "${progressPercent.toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff63b865),
                  ),
                ),
              ),
            ],
          ),

          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 25,
                  bottom: 8,
                  left: 26,
                  right: 26,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(10, (index) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: SvgPicture.asset(
                        'assets/svg/progress.svg',
                        color: index < (progressPercent / 10).floor()
                            ? Color(0xff63B865)
                            : Color(0xff63B865).withOpacity(0.3),
                        width: 35,
                        height: 13,
                      ),
                    );
                  }),
                ),
              ),
              if (progressPercent > 0)
                Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Stack(
                      children: [
                        Container(width: double.infinity, height: 35),
                        Positioned(
                          left: balloonLeftPosition(progressPercent) + 26,
                          bottom: 8,
                          child: ImageData(
                            IconsPath.progressPageImg,
                            width: 40,
                            height: 30,
                          ),
                        ),
                        Positioned(
                          left: balloonLeftPosition(progressPercent) +
                              calculateLeftOffset(pagesRead),
                          top: 3,
                          child: Center(
                            child: Text(
                              '$pagesRead' + 'p',
                              style: TextStyle(
                                  color: Color(0xff333333),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ))
            ],
          ),

          //Padding(
          //    padding: EdgeInsets.symmetric(horizontal: 26),
          //    child:
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 26),
                child: Text(
                  '0p',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff333333),
                  ),
                ),
              ),
              Spacer(),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  child: Text(
                    "${totalPages}p",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff333333),
                    ),
                  )),
            ],
          ),
          (recentHistory?.length ?? 0) != 0
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26, vertical: 2),
                  child: Row(
                    children: [
                      ImageData(IconsPath.information,
                          isSvg: true, width: 10, height: 10),
                      SizedBox(width: 3),
                      Text(
                        '마지막으로 ${recentHistory['startPage']}p-${recentHistory['endPage']}p만큼 읽었어요',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff63b865),
                        ),
                      ),
                    ],
                  ))
              : Padding(
                  padding: EdgeInsets.only(left: 26),
                  child: Row(
                    children: [
                      ImageData(IconsPath.information,
                          isSvg: true, width: 10, height: 10),
                      SizedBox(width: 2),
                      Text(
                        '독서 기록이 없어요',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff63b865),
                        ),
                      )
                    ],
                  ),
                )
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
