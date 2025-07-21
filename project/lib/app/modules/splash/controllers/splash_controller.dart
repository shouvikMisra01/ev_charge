import 'package:get/get.dart';
import '../../../data/services/firebase_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (_firebaseService.isLoggedIn) {
      Get.offAllNamed(AppRoutes.HOME);
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}