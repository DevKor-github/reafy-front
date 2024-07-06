import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:reafy_front/src/components/done.dart';
import 'package:reafy_front/src/components/new_book_memo.dart';
import 'package:reafy_front/src/models/memo.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:reafy_front/src/provider/memo_provider.dart';
import 'package:reafy_front/src/utils/constants.dart';
import 'package:reafy_front/src/repository/bookshelf_repository.dart';

class MemoCard extends StatefulWidget {
  final Memo memo;
  final String type;
  const MemoCard({Key? key, required this.memo, required this.type})
      : super(key: key);

  @override
  _MemoCardState createState() => _MemoCardState();
}

class _MemoCardState extends State<MemoCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MemoProvider>(builder: (context, memoProvider, child) {
      Memo? memo;
      if (widget.type == 'board')
        memo = memoProvider.findMemoById(widget.memo.memoId);
      else if (widget.type == 'book')
        memo = memoProvider.findBookMemoById(widget.memo.memoId);

      if (memo == null) {
        return SizedBox.shrink(); // 메모가 없으면 아무것도 표시하지 않음
      }

      final validHashtags =
          memo.hashtag.where((tag) => tag.isNotEmpty).toList();
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: Color(0xFFfbfbfb),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: gray.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 20,
              offset: Offset(0, 0),
            ),
          ],
        ),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MemoTitle(
                memoId: widget.memo.memoId,
                bookId: widget.memo.bookshelfBookId,
                memo: widget.memo),
            if (widget.memo.imageURL != null &&
                widget.memo.imageURL!.isNotEmpty)
              MemoImage(imageUrl: widget.memo.imageURL!),
            const SizedBox(height: 10),
            MemoDescription(content: widget.memo.content),
            const SizedBox(height: 10),
            if (validHashtags.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Wrap(
                  spacing: 5.0,
                  runSpacing: 5.0,
                  children: widget.memo.hashtag
                      .map((tag) => Hashtag(label: "#$tag"))
                      .toList(),
                ),
              ),
            const SizedBox(height: 5),
            Row(
              children: [
                Spacer(),
                Text(
                  widget.memo.updatedAt.toString(),
                  style: TextStyle(
                    color: Color(0xffb3b3b3),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class MemoTitle extends StatefulWidget {
  final int memoId;
  final int bookId;
  final Memo memo;

  const MemoTitle(
      {Key? key,
      required this.memoId,
      required this.bookId,
      required this.memo})
      : super(key: key);

  @override
  _MemoTitleState createState() => _MemoTitleState();
}

class _MemoTitleState extends State<MemoTitle> {
  String _title = '';

  @override
  void initState() {
    super.initState();
    _loadBookTitle();
  }

  void _loadBookTitle() async {
    try {
      BookshelfBookTitleDto bookTitleDto =
          await getBookshelfBookTitle(widget.bookId);
      String title = bookTitleDto.title;
      if (mounted) {
        setState(() {
          _title = title;
        });
      }
    } catch (e) {
      print("책 제목을 가져오는 중 오류 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        margin: EdgeInsets.only(bottom: 9),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
            child: Text(
              _title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: black,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              softWrap: true,
            ),
          ),
          //Spacer(),
          Container(
              width: 25,
              child: PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == 'edit') {
                    showAddBookMemoBottomSheet(context, widget.bookId,
                        memo: widget.memo);
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, widget.memoId, widget.bookId);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {'edit', 'delete'}.map((String choice) {
                    return PopupMenuItem<String>(
                        value: choice,
                        padding: EdgeInsets.all(0),
                        height: 28,
                        child: Container(
                            alignment: Alignment.center,
                            height: 28,
                            child: Text(choice == 'edit' ? "수정" : "삭제",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13))));
                  }).toList();
                },
                offset: Offset(15, 25),
                icon: Icon(Icons.more_horiz_rounded, color: gray, size: 18),
              )),
        ]));
  }
}

class MemoImage extends StatelessWidget {
  final String? imageUrl;
  final String baseUrl = 'https://dev.reafy.devkor.club/';

  const MemoImage({Key? key, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String fullImageUrl = (imageUrl ?? '');
    return imageUrl != null && imageUrl!.isNotEmpty
        ? GestureDetector(
            onTap: () => showImageDialog(context, fullImageUrl),
            child: Card(
              color: Color(0xffFAF9F7),
              elevation: 0,
              child: Container(
                width: double.maxFinite,
                height: 270,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(fullImageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          )
        : SizedBox.shrink();
  }

  void showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.transparent,
            content: Container(
                color: Colors.transparent,
                width: SizeConfig.screenWidth * 0.9,
                height: SizeConfig.screenHeight * 0.6,
                child: Stack(clipBehavior: Clip.hardEdge, children: [
                  PhotoView(
                    imageProvider: NetworkImage(imageUrl),
                    backgroundDecoration:
                        BoxDecoration(color: Colors.transparent),
                  ),
                  Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.cancel,
                            color: Color(0xFFFFD747), size: 24),
                      )),
                ])));
      },
    );
  }
}

class MemoDescription extends StatelessWidget {
  final String? content;
  const MemoDescription({Key? key, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: ExpandableText(
        content ?? '',
        prefixStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          color: black,
          fontSize: 12,
          height: 1.5,
        ),
        expandText: '더보기',
        collapseText: '접기',
        maxLines: 5,
        expandOnTextTap: true,
        collapseOnTextTap: true,
        linkColor: Colors.grey,
      ),
    );
  }
}

class Hashtag extends StatelessWidget {
  final String label;
  const Hashtag({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: label.length > 7 ? 85 : 60,
      padding: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Color(0xffFFECA6),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Color(0xff666666),
          ),
        ),
      ),
    );
  }
}

void _showDeleteDialog(BuildContext context, int memoId, int bookId) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 320,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(height: 40.0),
              Text(
                "정말 삭제하시겠어요? \n 작성한 메모는 영구적으로 사라져요!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xff333333),
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffebebeb),
                      minimumSize: Size(140, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '취소',
                      style: const TextStyle(
                        color: Color(0xff333333),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  ElevatedButton(
                    onPressed: () async {
                      //Navigator.pop(context);
                      try {
                        final memoProvider =
                            Provider.of<MemoProvider>(context, listen: false);
                        await memoProvider.deleteMemo(memoId);
                        Provider.of<MemoProvider>(context, listen: false)
                            .loadMemosByBookId(bookId, 1);
                        Navigator.pop(context);

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DoneDialog(onDone: () {});
                          },
                        );
                      } catch (e) {
                        print('메모 삭제 실패: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffffd747),
                      minimumSize: Size(140, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '확인',
                      style: const TextStyle(
                        color: Color(0xff000000),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ]),
          ),
          actions: <Widget>[],
        );
      });
}
