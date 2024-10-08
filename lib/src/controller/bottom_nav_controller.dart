import 'package:get/get.dart';

enum PageName { LIBRARY, HOME, MYPAGE }

class BottomNavController extends GetxController {
  static BottomNavController get to => Get.find();
  RxInt pageIndex = 1.obs;
  //GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  List<int> bottomHistory = [1];
  void changeBottomNav(int value, {bool hasGesture = true}) {
    var page = PageName.values[value];
    switch (page) {
      case PageName.LIBRARY:
      case PageName.HOME:
      case PageName.MYPAGE:
        _changePage(value, hasGesture: hasGesture);
        break;
    }
  }

  void _changePage(int value, {bool hasGesture = true}) {
    pageIndex(value);
    if (!hasGesture) return;
    if (bottomHistory.last != value) {
      bottomHistory.add(value);
    }
  }

  void goToHome() {
    changeBottomNav(PageName.HOME.index, hasGesture: true);
  }

  void goToBookShelf() {
    changeBottomNav(PageName.LIBRARY.index, hasGesture: true);
  }

  Future<bool> willPopAction() async {
    var page = PageName.values[bottomHistory.last];
    if (page == PageName.HOME) {
      return true;
    } else {
      changeBottomNav(1, hasGesture: false); // Home 이 아니라면 홈으로 이동
      return false;
    }
  }
}
