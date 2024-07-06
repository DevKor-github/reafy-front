import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:reafy_front/src/components/book_card.dart';
import 'package:reafy_front/src/components/image_data.dart';
import 'package:reafy_front/src/models/book.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';
import 'package:reafy_front/src/repository/bookshelf_repository.dart';
import 'package:reafy_front/src/utils/api.dart';
import 'package:reafy_front/src/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:reafy_front/src/utils/constants.dart';

class Quote {
  final String author;
  final String text;

  Quote({
    required this.author,
    required this.text,
  });
}

class SearchBook extends StatefulWidget {
  const SearchBook({super.key});

  @override
  State<SearchBook> createState() => _SearchBookState();
}

class _SearchBookState extends State<SearchBook> {
  List<Book> displayList = [];
  TextEditingController _searchController = TextEditingController();
  final Random _random = Random();

  bool isSearching = true;
  int currentPage = 1;
  int totalPages = 1;
  late Quote randomQuote;
  var searchResults;

  @override
  void initState() {
    super.initState();
    _selectRandomQuote();
  }

  void _selectRandomQuote() {
    final List<Quote> quotes = [
      Quote(text: "책 없는 방은 영혼 없는 육체와도 같다.", author: "키케로"),
      Quote(text: "좋은 책은 좋은 친구와 같다.", author: "생피에르"),
      Quote(text: "독서는 정신의 음악이다.", author: "소크라테스"),
      Quote(text: "독서는 하나의 창조 과정이다.", author: "에렌부르그"),
      Quote(text: "그저 생각하고, 생활을 위해 독서하라.", author: "베이컨"),
      Quote(text: "좋은 책은 인류에게 불멸의 정신이다.", author: "J.밀턴"),
      Quote(text: "내가 세계를 알게 된 것은 책에 의해서였다.", author: "사르트르"),
    ];
    randomQuote = quotes[_random.nextInt(quotes.length)];
  }

  Future<SearchBookResDto> searchBooks(String query, int page) async {
    final Dio authdio = authDio().getDio();

    try {
      final res = await authdio
          .get('/book/search', queryParameters: {'query': query, 'page': page});

      if (res.statusCode == 200) {
        var results = SearchBookResDto.fromJson(res.data);
        setState(() {
          searchResults = results;
        });
        return searchResults;
        //var searchResults = SearchBookResDto.fromJson(res.data);
        //return searchResults;
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      throw e;
    }
  }

  void _loadMore() {
    currentPage++;
    _performSearch(_searchController.text, currentPage);
  }

  void _performSearch(String query, [int page = 1]) {
    if (query.trim().isEmpty) {
      setState(() {
        isSearching = false;
        displayList = [];
        totalPages = 0;
      });
      return;
    }

    setState(() {
      isSearching = true;
      currentPage = page;
    });
    searchBooks(query, page).then((searchResults) {
      setState(() {
        isSearching = false;
        displayList = searchResults.items.map(convertToBook).toList();
        totalPages = searchResults.totalPages;
      });
    });
  }

  Widget _search() {
    return Container(
      width: 341,
      height: 40,
      child: TextField(
        controller: _searchController,
        onSubmitted: (query) {
          _performSearch(query);
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xffFFF7DA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color(0xffFFF7DA)),
          ),
          hintText: "어떤 책을 찾으세요?",
          hintStyle: TextStyle(
              color: Color(0xff666666),
              fontSize: 14,
              fontWeight: FontWeight.w400),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.search,
              color: Color(0xffFFCA0E),
            ),
            onPressed: () {
              _performSearch(_searchController.text);
            },
          ),
        ),
      ),
    );
  }

  Widget _character() {
    return Container(
      width: 228,
      height: 303, // Adjust height as needed
      child: ImageData(IconsPath.character_book),
    );
  }

  Widget _quotes() {
    return Positioned(
        bottom: 15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 11),
              width: 63,
              height: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                color: Color(0xffFFF7D9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  randomQuote.author,
                  style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
            Container(
              width: 245,
              height: 43,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFFFAF9F7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  randomQuote.text,
                  style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            )
          ],
        ));
  }

  Widget _buildPageNumbers(int totalPages) {
    int pageDisplayLimit = 5;
    int currentPageGroupStart =
        ((currentPage - 1) ~/ pageDisplayLimit) * pageDisplayLimit;

    List<Widget> pageNumbers = List.generate(
      min(pageDisplayLimit, totalPages - currentPageGroupStart),
      (index) {
        int pageNumber = currentPageGroupStart + index + 1;
        return GestureDetector(
          onTap: () {
            _loadPage(pageNumber);
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: currentPage == pageNumber
                  ? Color(0xffFFF7DA)
                  : Colors.transparent,
            ),
            child: Text('$pageNumber'),
          ),
        );
      },
    );

    // 이전 페이지 그룹으로 이동하는 버튼 추가 (첫 페이지 그룹이 아닐 경우)
    if (currentPageGroupStart > 0) {
      pageNumbers.insert(
        0,
        IconButton(
          icon: Icon(Icons.arrow_left),
          onPressed: () {
            _loadPage(currentPageGroupStart);
          },
        ),
      );
    }

    // 다음 페이지 그룹으로 이동하는 버튼 추가 (마지막 페이지 그룹이 아닐 경우)
    if (currentPageGroupStart + pageDisplayLimit < totalPages) {
      pageNumbers.add(
        IconButton(
          icon: Icon(Icons.arrow_right),
          onPressed: () {
            _loadPage(currentPageGroupStart + pageDisplayLimit + 1);
          },
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pageNumbers,
    );
  }

  void _loadPage(int pageNumber) {
    _performSearch(_searchController.text, pageNumber);
  }

  Widget _renderResults() {
    if (isSearching) {
      return Expanded(
          child: Transform.scale(
        origin: Offset(0, 100),
        scale: 1.5,
        child: Lottie.asset(
          'assets/lottie/searching.json',
        ),
      ));
    } else {
      double screenHeight = MediaQuery.of(context).size.height -
          AppBar().preferredSize.height -
          MediaQuery.of(context).padding.top;

      return Container(
        height: screenHeight - 60,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Color(0xFFFAF9F7),
            Color(0xFFEBEBEB),
            Color(0xFFEBEBEB),
            Color(0xFFFAF9F7)
          ],
          stops: [0, 0.1, 0.9, 1],
          transform: GradientRotation(1.5708),
        )),
        child: searchResults == null || searchResults.totalPages == 0
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImageData(IconsPath.character_empty,
                        width: 104, height: 94),
                    Text(
                      "검색 결과가 없어요!",
                      style: TextStyle(
                        color: gray,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: displayList.length,
                      itemBuilder: (context, index) => BookCard(
                        book: displayList[index],
                        isbn13: displayList[index].isbn13,
                      ),
                    ),
                  ),
                  _buildPageNumbers(totalPages),
                  SizedBox(height: 10),
                ],
              ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "책을 추가해주세요!",
            style: TextStyle(
                color: Color(0xff333333),
                fontWeight: FontWeight.w700,
                fontSize: 18),
          ),
          foregroundColor: Color.fromARGB(255, 22, 20, 20),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/addbook_background.png'),
                fit: BoxFit.fill,
              ),
            ),
            width: size.width,
            height: size.height,
            child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFAF9F7),
                      Color.fromRGBO(250, 249, 247, 0.0),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _searchController.text.isEmpty
                          ? <Widget>[
                              _search(),
                              Spacer(),
                              Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  _character(),
                                  _quotes(),
                                ],
                              ),
                              const SizedBox(height: 21)
                            ]
                          : <Widget>[_search(), _renderResults()]),
                ))));
  }
}
