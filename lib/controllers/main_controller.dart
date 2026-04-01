import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:messagex/controllers/friends_controller.dart';
import 'package:messagex/controllers/home_controller.dart';
import 'package:messagex/controllers/profile_controller.dart';
import 'package:messagex/controllers/users_list_controller.dart';

class MainController extends GetxController {
  final RxInt _currentIndex = 0.obs;
  final PageController pageController = PageController();

  int get currentIndex => _currentIndex.value;

  @override
  void onInit() {
    Get.lazyPut(() => ProfileController());
    Get.lazyPut( () => HomeController());
    Get.lazyPut( () => FriendsController());
    Get.lazyPut( () => UsersListController());

    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void changePage(int index) {
    _currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void onPageChanged(int index) {
    _currentIndex.value = index;
  }

  int getUnreadCount() {
    try {
      final homeController = Get.find<HomeController>();
      return homeController.getTotalUnreadCount();
  
    } catch (e) {
      return 0;
    }
  }

  int getNotificationCount() {
    try {
      final homeController = Get.find<HomeController>();
      return homeController.getUnreadNotificationsCount();
    } catch (e) {
      return 0;
    }
  }


  
}
