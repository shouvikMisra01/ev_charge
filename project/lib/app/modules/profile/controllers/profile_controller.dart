import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/firebase_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  
  final currentUser = Rxn<UserModel>();
  final isLoading = false.obs;
  final isDarkMode = false.obs;
  
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    isDarkMode.value = Get.isDarkMode;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;
      if (_firebaseService.currentUser != null) {
        final doc = await _firebaseService.getUserDocument(_firebaseService.currentUser!.uid);
        if (doc.exists) {
          currentUser.value = UserModel.fromFirestore(doc);
          nameController.text = currentUser.value!.name;
          phoneController.text = currentUser.value!.phone;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Name cannot be empty');
      return;
    }

    try {
      isLoading.value = true;
      
      await _firebaseService.updateUserDocument(
        _firebaseService.currentUser!.uid,
        {
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'updatedAt': DateTime.now(),
        },
      );
      
      await _loadUserData();
      
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void goToOwnerRegistration() {
    Get.toNamed(AppRoutes.OWNER_REGISTRATION);
  }

  void goToBookingsHistory() {
    Get.toNamed(AppRoutes.BOOKINGS_HISTORY);
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      Get.offAllNamed(AppRoutes.LOGIN);
      Get.snackbar(
        'Success',
        'Signed out successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out');
    }
  }

  void showSignOutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              signOut();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void showEditProfileDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              updateProfile();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}