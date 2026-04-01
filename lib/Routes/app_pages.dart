import 'package:get/get.dart';
import 'package:messagex/Routes/app_routes.dart';
import 'package:messagex/controllers/chat_controller.dart';
import 'package:messagex/controllers/friends_controller.dart';
import 'package:messagex/controllers/friends_request_controller.dart';
import 'package:messagex/controllers/home_controller.dart';
import 'package:messagex/controllers/main_controller.dart';
import 'package:messagex/controllers/profile_controller.dart';
import 'package:messagex/controllers/users_list_controller.dart';
import 'package:messagex/screens/auth/forgot_password_view.dart';
import 'package:messagex/screens/auth/login_view.dart';
import 'package:messagex/screens/auth/register_view.dart';
import 'package:messagex/screens/chat_view.dart';
import 'package:messagex/screens/find_people_view.dart';
import 'package:messagex/screens/friend_requests_view.dart';
import 'package:messagex/screens/friends_view.dart';
import 'package:messagex/screens/home_view.dart';
import 'package:messagex/screens/profile/change_password_view.dart';
import 'package:messagex/screens/main_view.dart';
import 'package:messagex/screens/profile/profile_view.dart';
import 'package:messagex/screens/splash_view.dart';

class AppPages {
  static const initial = AppRoutes.splash;
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),

    GetPage(name: AppRoutes.login, page: () => const LoginView()),

    GetPage(name: AppRoutes.register, page: () => const RegisterView()),

    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordView()),

    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
    ),

    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      binding: BindingsBuilder(() {
        Get.put(MainController());
      }),
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => HomeView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
    ),

    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      }),
    ),

        GetPage(
      name: AppRoutes.chat,
      page: () =>  ChatView(),
      binding: BindingsBuilder(() {
        Get.put(ChatController());
      }),
    ),
    GetPage(
      name: AppRoutes.usersList,
      page: () => const FindPeopleView(),
      binding: BindingsBuilder(() {
        Get.put(UsersListController());
      }),
    ),

    GetPage(
      name: AppRoutes.friends,
      page: () => const FriendsView(),
      binding: BindingsBuilder(() {
        Get.put(FriendsController());
      }),
    ),

    GetPage(
      name: AppRoutes.friendRequests,
      page: () => const FriendRequestsView(),
      binding: BindingsBuilder(() {
        Get.put(FriendsRequestController());
      }),
    ),

    //     GetPage(
    //   name: AppRoutes.notifications,
    //   page: () => const NotificationsView(),
    //   binding: BindingsBuilder(() {
    //     Get.put(NotificationsController());
    //   }),
    // ),
  ];
}
