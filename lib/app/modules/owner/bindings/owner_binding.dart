import 'package:get/get.dart';
import '../controllers/owner_controller.dart';

class OwnerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OwnerController>(() => OwnerController());
  }
}