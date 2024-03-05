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

class newBookMemo extends StatefulWidget {
  final int bookshelfBookId;
  final Memo? memo;

  const newBookMemo({
    Key? key,
    required this.bookshelfBookId,
    this.memo,
  }) : super(key: key);

  @override
  State<newBookMemo> createState() => _newBookMemoState();
}

class _newBookMemoState extends State<newBookMemo> {
  DateTime selectedDate = DateTime.now();
  int currentLength = 0;

  List<ReadingBookInfo> books = [];
  int? selectedBookId;
  List<String> memoTags = [];
  // File? imageFile;
  String? selectedImagePath;

  final TextEditingController memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedBookId = widget.bookshelfBookId;
    selectedDate = DateTime.now();

    if (widget.memo != null) {
      memoController.text = widget.memo!.content;
      //selectedDate = widget.memo!.createdAt;
      memoTags = widget.memo!.hashtag;
      selectedImagePath = widget.memo!.imageURL;
    } else {
      selectedDate = DateTime.now();
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

  void handleImagePicked(String path) {
    selectedImagePath = path;
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

  Widget _memoeditor() {
    return Container(
      width: 343,
      height: 201,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: white,
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 13),
              width: 317,
              child: TextField(
                maxLength: 500,
                maxLines: null,
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      padding: EdgeInsets.symmetric(vertical: 35, horizontal: 23),
      color: bg_gray,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PickImage(
            onImagePicked: handleImagePicked,
            imagePath: selectedImagePath,
          ),
          SizedBox(height: 25),
          SizedBox(height: 6.0),
          _memoeditor(),
          SizedBox(height: 16.0),
          _datepicker(context),
          TagWidget(
              onTagsUpdated: handleTagUpdate,
              onReset: resetTags,
              initialTags: memoTags),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              if (selectedBookId == null) {
                print('필요한 정보가 누락되었습니다.');
                return;
              }
              String tags = memoTags.join(', ');
              try {
                if (widget.memo == null) {
                  //메모 생성
                  Memo newMemo = await createMemo(selectedBookId!,
                      memoController.text, 0, tags, selectedImagePath);
                  Provider.of<MemoProvider>(context, listen: false)
                      .addBookMemo(newMemo);
                } else {
                  //메모 수정
                  Memo updatedMemo = await updateMemo(widget.memo!.memoId,
                      memoController.text, 0, tags, selectedImagePath);
                  Provider.of<MemoProvider>(context, listen: false)
                      .updateBookMemo(updatedMemo);
                }

                Navigator.pop(context);
              } catch (e) {
                print('메모 생성 실패: $e');
              }
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Color(0xFFFFD747),
                shadowColor: Colors.black.withOpacity(0.1),
                elevation: 5,
                fixedSize: Size(343, 38)),
            child: Text(
              '게시하기',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xffffffff),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

void showAddBookMemoBottomSheet(BuildContext context, int bookshelfBookId,
    {Memo? memo}) {
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
      return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
        child: Container(
          color: bg_gray,
          child: newBookMemo(bookshelfBookId: bookshelfBookId, memo: memo),
        ),
      );
    },
  );
}