import 'package:get/get.dart';
import '../../../data/services/firebase_service.dart';
import '../../../data/models/user_model.dart';

class HomeController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  
  final currentIndex = 0.obs;
  final currentUser = Rxn<UserModel>();
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  Future<void> _loadUserData() async {
    try {
      if (_firebaseService.currentUser != null) {
        final doc = await _firebaseService.getUserDocument(_firebaseService.currentUser!.uid);
        if (doc.exists) {
          currentUser.value = UserModel.fromFirestore(doc);
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool get canShowOwnerTab {
    return currentUser.value?.userType == 'provider' || 
           currentUser.value?.userType == 'both';
  }

  Future<void> refreshUserData() async {
    await _loadUserData();
  }
}