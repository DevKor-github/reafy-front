import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reafy_front/src/dto/bookshelf_dto.dart';
import 'package:reafy_front/src/provider/state_book_provider.dart';
import 'package:reafy_front/src/components/image_data.dart';
import 'package:reafy_front/src/components/dialog/delete_book2.dart';
import 'package:reafy_front/src/repository/bookshelf_repository.dart';
import 'package:provider/provider.dart';
import 'package:reafy_front/src/provider/selectedbooks_provider.dart';
import 'package:reafy_front/src/pages/book/bookdetail.dart';

class Category_BookShelf extends StatefulWidget {
  final String pageTitle;

  const Category_BookShelf({
    required this.pageTitle,
    Key? key,
  }) : super(key: key);

  @override
  _C_BookShelfState createState() => _C_BookShelfState();
}

class _C_BookShelfState extends State<Category_BookShelf>
    with TickerProviderStateMixin {
  late int progressState = (widget.pageTitle == "읽고 있는 책") ? 1 : 2;
  late List<BookshelfBookInfo> books = [];

  late AnimationController _shakeController;
  late Tween<double> _shakeTween = Tween<double>(begin: -0.005, end: 0.005);

  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    _shakeController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    SelectedBooksProvider selectedBooksProvider =
        Provider.of<SelectedBooksProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xff63b865)),
          onPressed: () {
            selectedBooksProvider.clearBooks();
            Provider.of<BookShelfProvider>(context, listen: false).fetchData();
            Get.back();
          },
        ),
        title: Text(
          isEditMode ? '삭제할 책을 선택해 주세요!' : widget.pageTitle,
          style: TextStyle(
              color: Color(0xff333333),
              fontWeight: isEditMode ? FontWeight.w400 : FontWeight.w800,
              fontSize: 16),
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 10),
            iconSize: 44,
            icon: isEditMode
                ? ImageData(IconsPath.check_green,
                    isSvg: true, width: 44, height: 44)
                : ImageData(IconsPath.trash_can, isSvg: true),
            onPressed: () {
              if (isEditMode &&
                  selectedBooksProvider.selectedBooks.length > 0) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DeleteDialog(
                      onConfirmDelete: () {
                        setState(() {
                          isEditMode = false;
                        });
                      },
                    );
                  },
                );
              } else {
                setState(() {
                  isEditMode = !isEditMode;
                });
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/green_bg2.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: fetchBookshelfBooksInfoByState(progressState),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    books = snapshot.data as List<BookshelfBookInfo>;
                    return _buildCategoryBookShelfWidget(books);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShakeAnimation(BookshelfBookInfo book, isSelected) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        RotationTransition(
          turns: _shakeTween.animate(_shakeController),
          child: Container(
            width: (size.width - 56 - 50) / 3,
            height: (size.width - 56 - 50) / 9 * 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              border: isSelected
                  ? Border.all(
                      color: Color(0xffffd747),
                      width: 3.0,
                    )
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: Image.network(
                book.thumbnailURL,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // 이미지를 불러오는 데 실패한 경우의 처리
                  return const Text('이미지를 불러올 수 없습니다.');
                },
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(0xffffd747).withOpacity(0.5) //0.7
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBookShelfWidget(List<BookshelfBookInfo> books) {
    final size = MediaQuery.of(context).size;

    return ChangeNotifierProvider.value(
      value: Provider.of<SelectedBooksProvider>(context),
      child: Consumer<SelectedBooksProvider>(
        builder: (context, selectedBooksProvider, child) {
          return Container(
            margin: EdgeInsets.only(top: 22),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "총 ${books.length}권",
                    style: TextStyle(
                      color: Color(0xff333333),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 22),
                  Container(
                    height: MediaQuery.of(context).size.height - 200,
                    child: GridView.builder(
                      padding: EdgeInsets.all(8.0),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 한 행에 표시할 아이템 수
                        crossAxisSpacing: 28.0, // 아이템 간 가로 간격
                        mainAxisSpacing: 10.0, // 아이템 간 세로 간격
                        childAspectRatio: size.width > 768 ? 0.6 : 0.5,
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        bool isSelected =
                            selectedBooksProvider.selectedBooks.contains(book);

                        return GestureDetector(
                          onTap: () {
                            if (isEditMode) {
                              setState(() {
                                if (isSelected) {
                                  selectedBooksProvider.removeBook(book);
                                } else {
                                  selectedBooksProvider.addBook(book);
                                }
                              });
                            } else {
                              Get.to(() => BookDetailPage(
                                  bookshelfBookId: book.bookshelfBookId));
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              isEditMode
                                  ? _buildShakeAnimation(book, isSelected)
                                  : Container(
                                      width: (size.width - 56 - 50) / 3,
                                      height: (size.width - 56 - 50) / 9 * 4,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                        color: Color(0xffffffff),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          book.thumbnailURL,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Text(
                                                '이미지를 불러올 수 없습니다.');
                                          },
                                        ),
                                      ),
                                    ),
                              SizedBox(height: 5),
                              Text(
                                book.title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff333333),
                                ),
                              ),
                              Text(
                                book.author,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff333333),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
