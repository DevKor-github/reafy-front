import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:reafy_front/src/app.dart';
import 'package:reafy_front/src/components/dialog/done.dart';
import 'package:reafy_front/src/dto/bookshelf_dto.dart';
import 'package:reafy_front/src/dto/history_dto.dart';
import 'package:reafy_front/src/provider/stopwatch_provider.dart';
import 'package:reafy_front/src/provider/time_provider.dart';
import 'package:reafy_front/src/repository/bookshelf_repository.dart';
import 'package:reafy_front/src/repository/history_repository.dart';
import 'package:reafy_front/src/repository/timer_repository.dart';
import 'package:toastification/toastification.dart';

class StopDialog extends StatefulWidget {
  @override
  _StopDialogState createState() => _StopDialogState();
}

class _StopDialogState extends State<StopDialog> {
  List<ReadingBookInfoDto> books = [];
  int? selectedBookId;
  bool _isStartPageValid = true;
  bool _isEndPageValid = true;
  bool _isShelfEmpty = false;
  int? lastReadPage;
  int? limitedEndPage;

  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  bool isButtonEnabled = false;
  Map<String, dynamic>? remainedTimer;

  void updateButtonState() {
    setState(() {
      isButtonEnabled = _isStartPageValid &&
          _isEndPageValid &&
          textController1.text.isNotEmpty &&
          textController2.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchReadingBooksInfo(1).then((fetchedBooks) {
      setState(() {
        books = fetchedBooks;
        if (books.isNotEmpty) {
          selectedBookId = books[0].bookshelfBookId;
          fetchLastReadingHistory(selectedBookId!);
          getBookEndPage(selectedBookId!);
        } else {
          _isShelfEmpty = true;
        }
      });
    });
    fetchTimerData();
  }

  Future<void> fetchTimerData() async {
    try {
      final data = await getRemainingTime();
      setState(() {
        remainedTimer = data;
      });
    } catch (e) {
      print('Error fetching user timer data: $e');
    }
  }

  void getBookEndPage(int bookId) async {
    var data = await getBookshelfBookDetails(bookId);
    setState(() {
      limitedEndPage = data.pages;
    });
  }

  void fetchLastReadingHistory(int bookId) async {
    var history = await getBookshelfBookRecentHistory(bookId);
    if (history != null && history.isNotEmpty) {
      setState(() {
        textController1.text =
            (history['endPage'] + 1).toString(); // endPage 다음 페이지로 설정
      });
    } else {
      setState(() {
        textController1.text = '';
      });
    }
    _validatePageInput();
  }

  void _onBookChanged(int? newValue) {
    if (newValue == null) return;
    setState(() {
      selectedBookId = newValue;
      fetchLastReadingHistory(newValue);
      getBookEndPage(newValue);
    });
  }

  void _validatePageInput() {
    bool startPageValid = textController1.text.isEmpty ||
        int.tryParse(textController1.text) != null;
    bool endPageValid = textController2.text.isEmpty ||
        int.tryParse(textController2.text) != null;

    setState(() {
      _isStartPageValid = startPageValid;
      _isEndPageValid = endPageValid;
    });

    updateButtonState();
  }

  int calculateRemainedTimer(int readingTime, {int? remainedTimer}) {
    if (remainedTimer != null) {
      // remainedTimer가 존재할 경우
      int newRemainedTimer = remainedTimer - readingTime;
      while (newRemainedTimer <= 0) {
        newRemainedTimer += 900;
      }
      return newRemainedTimer == 0 ? 900 : newRemainedTimer;
    } else {
      // remainedTimer가 존재하지 않을 경우
      int multipleOfFifteenMinutes = (readingTime / 900).ceil() * 900;
      int remainedTimer = multipleOfFifteenMinutes - readingTime;
      return remainedTimer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StopwatchProvider>(builder: (context, stopwatch, child) {
      return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SingleChildScrollView(
              child: Container(
            //width: 320,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 30.0),
                Text(
                  stopwatch.elapsedTimeString,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 14.0),
                const Text(
                  "독서 내용을 기록해주세요!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 14.0),
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(top: 36.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "읽은 책:",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff666666),
                            ),
                          ),
                          Spacer(),
                          if (_isShelfEmpty)
                            Text(
                              '책장에 책을 추가해보세요 ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Container(
                        padding: EdgeInsets.all(2.0),
                        //width: 266,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Color(0xffffffff),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1.0,
                              blurRadius: 7.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButton<int>(
                          isExpanded: true,
                          underline: Container(),
                          value: selectedBookId,
                          selectedItemBuilder: (BuildContext context) {
                            return books.map<Widget>((ReadingBookInfoDto book) {
                              return Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 10.0),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        book.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xff666666),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      )));
                            }).toList();
                          },
                          items: books.map((ReadingBookInfoDto book) {
                            return DropdownMenuItem<int>(
                              value: book.bookshelfBookId,
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  2.0,
                                ),
                                child: Text(
                                  book.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff666666),
                                  ),
                                  overflow: TextOverflow.clip,
                                  maxLines: null,
                                  softWrap: true,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: _onBookChanged,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20.0),
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "읽은 페이지:",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff666666),
                            ),
                          ),
                          Spacer(),
                          if (!_isStartPageValid || !_isEndPageValid)
                            Text(
                              '숫자를 입력해주세요',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              //width: 120,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius: BorderRadius.circular(4),
                                border: !_isStartPageValid
                                    ? Border.all(color: Colors.red, width: 2)
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1.0,
                                    blurRadius: 7.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text(
                                      '시작',
                                      style: TextStyle(
                                          color: Color(0xff666666),
                                          fontSize: 13),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: textController1,
                                      onChanged: (_) {
                                        updateButtonState();
                                        _validatePageInput();
                                      },
                                      textAlign: TextAlign.right,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: Text(
                                      'p',
                                      style: TextStyle(
                                          color: textController1.text.isNotEmpty
                                              ? Color(0xff333333)
                                              : Color(0xff666666),
                                          fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              width: 120,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius: BorderRadius.circular(4),
                                border: !_isEndPageValid
                                    ? Border.all(color: Colors.red, width: 2)
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1.0,
                                    blurRadius: 7.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text(
                                      '끝',
                                      style: TextStyle(
                                          color: Color(0xff666666),
                                          fontSize: 13),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: textController2,
                                      onChanged: (_) {
                                        updateButtonState();
                                        _validatePageInput();
                                      },
                                      textAlign: TextAlign.right,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: Text(
                                      'p',
                                      style: TextStyle(
                                          color: textController2.text.isNotEmpty
                                              ? Color(0xff333333)
                                              : Color(0xff666666),
                                          fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: isButtonEnabled
                          ? () async {
                              int readingTime = parseTimeStringToSeconds(
                                  stopwatch.elapsedTimeString);
                              int? startPage =
                                  int.tryParse(textController1.text);
                              int? endPage = int.tryParse(textController2.text);

                              if (startPage! > endPage!) {
                                toastification.show(
                                  context: context,
                                  type: ToastificationType.error,
                                  style: ToastificationStyle.flatColored,
                                  title: Text('정확한 페이지를 입력해주세요'),
                                  autoCloseDuration: const Duration(seconds: 2),
                                  showProgressBar: false,
                                );
                              } else if (startPage > limitedEndPage! ||
                                  endPage > limitedEndPage!) {
                                toastification.show(
                                  context: context,
                                  type: ToastificationType.error,
                                  style: ToastificationStyle.flatColored,
                                  title: Text('책의 전체 페이지수를 초과할수 없어요'),
                                  autoCloseDuration: const Duration(seconds: 2),
                                  showProgressBar: false,
                                );
                              } else {
                                CreateUserBookHistoryDto historyDto =
                                    CreateUserBookHistoryDto(
                                  bookshelfBookId: selectedBookId,
                                  startPage: startPage,
                                  endPage: endPage,
                                  duration: readingTime,
                                  remainedTimer: calculateRemainedTimer(
                                      readingTime,
                                      remainedTimer:
                                          remainedTimer?['timer'] as int),
                                );
                                await createUserBookHistory(historyDto);

                                context.read<StopwatchProvider>().stop();
                                // context
                                //     .read<StopwatchProvider>()
                                //     .updateElapsedTime(Duration.zero);

                                await Provider.of<TimeProvider>(context,
                                        listen: false)
                                    .getTimes();

                                Get.back(closeOverlays: true);
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return DoneDialog(onDone: () {
                                      Get.to(() => App(),
                                          transition: Transition.leftToRight);
                                    });
                                  },
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isButtonEnabled
                            ? Color(0xffffd747)
                            : Color(0xffebebeb),
                        minimumSize: Size(286, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '독서 완료하기',
                        style: const TextStyle(
                          color: Color(0xff333333),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        context.read<StopwatchProvider>().resume();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffffffff),
                        minimumSize: Size(286, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '계속 읽기',
                        style: const TextStyle(
                          color: Color(0xff333333),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )));
    });
  }
}

int parseTimeStringToSeconds(String timeString) {
  List<String> parts = timeString.split(':');
  if (parts.length != 3) {
    return 0;
  }
  int hours = int.tryParse(parts[0]) ?? 0;
  int minutes = int.tryParse(parts[1]) ?? 0;
  int seconds = int.tryParse(parts[2]) ?? 0;

  int totalSeconds = hours * 3600 + minutes * 60 + seconds;

  return totalSeconds;
}
