import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../user/controllers/user_controller.dart';
import '../../owner/controllers/owner_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<UserController>(() => UserController());
    Get.lazyPut<OwnerController>(() => OwnerController());
  }
}