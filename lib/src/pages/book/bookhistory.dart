import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reafy_front/src/components/image_data.dart';
import 'package:reafy_front/src/repository/bookshelf_repository.dart';
import 'package:reafy_front/src/repository/history_repository.dart';
import 'package:reafy_front/src/utils/constants.dart';
import 'package:reafy_front/src/utils/historyUtil.dart';

class BookHistory extends StatefulWidget {
  final int bookshelfBookId;

  const BookHistory({
    required this.bookshelfBookId,
    Key? key,
  }) : super(key: key);

  @override
  _BookHistory createState() => _BookHistory();
}

class _BookHistory extends State<BookHistory> {
  Map<String, dynamic> historyList = {};
  String bookTitle = '';
  bool isLoading = true;
  Map<String, dynamic> metaData = {};
  bool hasNextData = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchBookHistory();
    getBookTitle();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (hasNextData && !isLoading) {
        fetchBookHistory(cursorId: metaData['cursorId']);
      }
    }
  }

  void fetchBookHistory({int? cursorId}) async {
    if (!hasNextData) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await getBookshelfBookHistory(widget.bookshelfBookId,
          cursorId: cursorId);
      final newHistory = response['data'] as Map<String, dynamic>;
      metaData = response['meta'];

      setState(() {
        historyList.addAll(newHistory);
        //historyList = response['data'] as Map<String, dynamic>;
        hasNextData = metaData['hasNextData'];
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching book history in historyPage: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void getBookTitle() async {
    try {
      BookshelfBookTitleDto bookTitleDto =
          await getBookshelfBookTitle(widget.bookshelfBookId);
      setState(() {
        bookTitle = bookTitleDto.title;
      });
    } catch (e) {
      print('Error fetching book title in historyPage: $e');
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
          icon: Icon(Icons.arrow_back_ios, color: Color(0xff333333)),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          bookTitle,
          style: TextStyle(
              color: Color(0xff333333),
              fontWeight: FontWeight.w700,
              fontSize: 16),
          overflow: TextOverflow.clip,
          maxLines: null,
          softWrap: true,
        ),
      ),
      body: Center(
        child: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          decoration: BoxDecoration(color: Color(0xffFAF9F7)),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : historyList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageData(IconsPath.character_empty,
                              width: 120, height: 110),
                          Text(
                            "독서 기록이 없어요!",
                            style: TextStyle(
                              color: gray,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      key: PageStorageKey<String>('book-history-list'),
                      controller: _scrollController,
                      itemCount: historyList.length,
                      itemBuilder: (context, index) {
                        String date = historyList.keys.elementAt(index);
                        List<dynamic> records = historyList[date];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              date,
                              style: TextStyle(
                                  color: Color(0xff666666),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                            SizedBox(height: 12),
                            ...records.map((record) {
                              return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  width: size.width - 50,
                                  decoration: BoxDecoration(
                                    color: Color(0xffffffff),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        spreadRadius: 0,
                                        blurRadius: 20,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          record['createdAt'],
                                          style: TextStyle(
                                              color: Color(0xff666666),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              formatDuration(
                                                  record['duration']),
                                              style: TextStyle(
                                                  color: Color(0xff333333),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                              ' 동안',
                                              style: TextStyle(
                                                  color: Color(0xff666666),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                        Row(children: [
                                          Text(
                                            '${record['startPage']}p부터 ${record['endPage']}p까지',
                                            style: TextStyle(
                                                color: Color(0xff333333),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          Text(
                                            ' 읽었어요',
                                            style: TextStyle(
                                                color: Color(0xff666666),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ));
                            }).toList(),
                          ],
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
