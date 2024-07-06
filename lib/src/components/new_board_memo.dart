import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reafy_front/src/components/image_picker.dart';
import 'package:reafy_front/src/models/memo.dart';
import 'package:reafy_front/src/provider/memo_provider.dart';
import 'package:reafy_front/src/repository/memo_repository.dart';
import 'package:reafy_front/src/utils/constants.dart';
import 'package:reafy_front/src/components/image_data.dart';
import 'package:reafy_front/src/components/tag_input.dart';
import 'package:reafy_front/src/repository/bookshelf_repository.dart';
import 'package:toastification/toastification.dart';

class NewBoardMemo extends StatefulWidget {
  final Memo? memo;

  const NewBoardMemo({
    Key? key,
    this.memo,
  }) : super(key: key);

  @override
  State<NewBoardMemo> createState() => _NewBoardMemoState();
}

class _NewBoardMemoState extends State<NewBoardMemo> {
  DateTime selectedDate = DateTime.now();
  int currentLength = 0;
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  List<ReadingBookInfo> books = [];
  int? selectedBookId;
  List<String> memoTags = [];
  String? selectedImagePath;

  final TextEditingController memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBooks();
    selectedDate = DateTime.now();

    if (widget.memo != null) {
      memoController.text = widget.memo!.content;
      memoTags = widget.memo!.hashtag;
      selectedImagePath = widget.memo!.imageURL;
    } else {
      selectedDate = DateTime.now();
    }
  }

  void fetchBooks() async {
    try {
      final results = await Future.wait([
        fetchReadingBooksInfo(1),
        fetchReadingBooksInfo(2),
      ]);

      final allBooks = [...results[0], ...results[1]];

      setState(() {
        books = allBooks;
        if (books.isNotEmpty) {
          selectedBookId = books[0].bookshelfBookId;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    memoController.dispose();
    super.dispose();
  }

  void handleTagUpdate(List<String> updatedTags) {
    setState(() {
      memoTags = updatedTags;
    });
  }

  void resetTags() {
    setState(() {
      memoTags.clear();
    });
  }

  void handleImagePicked(String? path) {
    selectedImagePath = path;
  }

  Future<void> updateMemoState() async {
    if (selectedBookId == null) {
      print('필요한 정보가 누락되었습니다.');
      return;
    }
    String tags = memoTags.join(', ');

    try {
      if (widget.memo == null) {
        if (memoController.text == '') {
          toastification.show(
              context: context,
              type: ToastificationType.error,
              style: ToastificationStyle.flatColored,
              title: Text('내용을 입력해주세요'),
              autoCloseDuration: const Duration(seconds: 2),
              showProgressBar: false);
        } else {
          isLoading.value = true;
          //메모 생성
          Memo newMemo = await createMemo(
              selectedBookId!, memoController.text, 0, tags, selectedImagePath);
          Provider.of<MemoProvider>(context, listen: false)
              .addBoardMemo(newMemo);
          //Provider.of<MemoProvider>(context, listen: false).loadAllMemos(1);
          Navigator.pop(context);
        }
      } else {
        //메모 수정
        Memo updatedMemo = await updateMemo(widget.memo!.memoId,
            memoController.text, 0, tags, selectedImagePath);
        Provider.of<MemoProvider>(context, listen: false)
            .updateBookMemo(updatedMemo);
        isLoading.value = false;
        Navigator.pop(context);
      }
    } catch (e) {
      isLoading.value = false;
      print('메모 생성 또는 업데이트 실패: $e');
    }
  }

  Widget _datepicker(context) {
    return Container(
      height: 34,
      child: Row(
        children: [
          ImageData(
            IconsPath.memo_date,
            isSvg: true,
            width: 13,
            height: 13,
          ),
          SizedBox(width: 10),
          Text(
            "작성일",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xff666666),
            ),
          ),
          SizedBox(width: 4),
          Text(
            "${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일 ${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookselect() {
    return Container(
      height: 40,
      child: Row(
        children: [
          ImageData(
            IconsPath.memo_book,
            isSvg: true,
            width: 13,
            height: 13,
          ),
          SizedBox(width: 10),
          Text(
            "도서",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xff666666),
            ),
          ),
          SizedBox(width: 18),
          Container(
            width: 270,
            height: 35,
            decoration: BoxDecoration(
              color: bg_gray,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1.0,
                  blurRadius: 7.0,
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                  isExpanded: true,
                  underline: Container(),
                  value: selectedBookId,
                  selectedItemBuilder: (BuildContext context) {
                    return books.map<Widget>((ReadingBookInfo book) {
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
                  items: books.map((ReadingBookInfo book) {
                    return DropdownMenuItem<int>(
                      value: book.bookshelfBookId,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
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
                      //child: Text(item),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedBookId = newValue;
                    });
                  }),
            ),
          )
        ],
      ),
    );
  }

  Widget _memoeditor() {
    return Container(
        width: 343,
        constraints: BoxConstraints(maxHeight: 190),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: white,
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 13),
                  padding: EdgeInsets.symmetric(vertical: 5),
                  width: 317,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextField(
                          //maxLength: 500,
                          maxLines: null,
                          minLines: 1,
                          controller: memoController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '메모를 입력해 주세요.',
                            hintStyle: TextStyle(
                              color: Color(0xffb3b3b3),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          style: TextStyle(
                              color: dark_gray,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              height: 1.3),
                          onChanged: (text) {
                            setState(() {
                              currentLength = text.length;
                            });
                          },
                        ),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: Text(currentLength.toString() + '/500'))
                      ])),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
        child: SingleChildScrollView(
      //child: Container(
      padding: EdgeInsets.only(
        bottom: bottomPadding + 25, // 키보드 위의 '게시하기' 버튼이 보이도록 추가 여백을 제공합니다.
        top: 35,
        left: 23,
        right: 23,
      ),
      //color: bg_gray,
      child: Column(
        //mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PickImage(
            onImagePicked: handleImagePicked,
            imagePath: selectedImagePath,
          ),
          SizedBox(height: 25),
          _bookselect(),
          SizedBox(height: 6.0),
          _memoeditor(),
          SizedBox(height: 16.0),
          _datepicker(context),
          TagWidget(
              onTagsUpdated: handleTagUpdate,
              onReset: resetTags,
              initialTags: memoTags),
          SizedBox(height: 16.0),
          ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (context, loading, child) {
                return ElevatedButton(
                  onPressed: () => updateMemoState(),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Color(0xFFFFD747),
                      shadowColor: Colors.black.withOpacity(0.1),
                      elevation: 5,
                      fixedSize: Size(343, 38)),
                  child: loading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            white,
                          ),
                        )
                      : Text(
                          '게시하기',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffffffff),
                          ),
                        ),
                );
              })
        ],
      ),
    ));
  }
}

void showAddMemoBottomSheet(BuildContext context, {Memo? memo}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40.0),
        topRight: Radius.circular(40.0),
      ),
    ),
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          child: Container(
            color: bg_gray,
            child: NewBoardMemo(memo: memo),
          ),
        ),
        behavior: HitTestBehavior.opaque,
      );
    },
  );
}
