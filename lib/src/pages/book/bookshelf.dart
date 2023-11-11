import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reafy_front/src/components/image_data.dart';
import 'package:reafy_front/src/components/shelfwidget.dart';
import 'package:reafy_front/src/pages/book/addbook.dart';

class BookShelf extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BookShelfState();
  }
}

class _BookShelfState extends State<BookShelf> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            padding: EdgeInsets.all(0),
            icon: ImageData(IconsPath.add, isSvg: true, width: 20),
            onPressed: () {
              Get.to(SearchBook());
            },
          ),
          actions: [
            IconButton(
              padding: EdgeInsets.only(right: 21),
              icon: ImageData(IconsPath.trash_can, isSvg: true, width: 20),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
            child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/green_bg.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                width: size.width,
                height: size.height,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      BookShelfWidget(),
                      SizedBox(height: 20),
                      BookShelfWidget(),
                      SizedBox(height: 20),
                      BookShelfWidget(),
                      /*
                      Container(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                            CarouselSlider(
                              items: shelfSliders,
                              carouselController: _controller,
                              options: CarouselOptions(
                                  viewportFraction: 0.5,
                                  height: size.height * 0.7,
                                  autoPlay: false,
                                  enlargeCenterPage: true,
                                  aspectRatio: 1.0, //0.75,
                                  enlargeStrategy:
                                      CenterPageEnlargeStrategy.zoom,
                                  enlargeFactor: 0.5,
                                  scrollDirection: Axis.vertical,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _current = index;
                                    });
                                  }),
                            ),
                            //const Spacer(), //izedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  shelfSliders.asMap().entries.map((entry) {
                                return GestureDetector(
                                    onTap: () =>
                                        _controller.animateToPage(entry.key),
                                    child: Container(
                                      width: 15.0,
                                      height: 9.0,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 20.0, horizontal: 4.0),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _current == entry.key
                                              ? Color(0xff969696)
                                              : Color(0xffD9D9D9)),
                                    ));
                              }).toList(),
                            ),
                          
                          */
                    ]))));
  }
}
