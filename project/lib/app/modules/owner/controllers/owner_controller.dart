import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../data/services/firebase_service.dart';
import '../../../data/models/provider_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../routes/app_routes.dart';

class OwnerController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  
  final myProviders = <ProviderModel>[].obs;
  final upcomingBookings = <BookingModel>[].obs;
  final isLoading = false.obs;
  final totalEarnings = 0.0.obs;
  
  // Registration form controllers
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final priceController = TextEditingController();
  final selectedChargerType = 'slow'.obs;
  final selectedDays = <String>[].obs;
  final startTime = '09:00'.obs;
  final endTime = '18:00'.obs;
  final selectedImages = <File>[].obs;
  final selectedDocuments = <File>[].obs;
  final isSubmitting = false.obs;

  final List<String> weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  final List<String> chargerTypes = ['slow', 'fast', 'ac', 'dc'];

  @override
  void onInit() {
    super.onInit();
    _loadOwnerData();
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    priceController.dispose();
    super.onClose();
  }

  Future<void> _loadOwnerData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        _loadMyProviders(),
        _loadUpcomingBookings(),
      ]);
      _calculateEarnings();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMyProviders() async {
    if (_firebaseService.currentUser == null) return;
    
    final querySnapshot = await _firebaseService.providersCollection
        .where('userId', isEqualTo: _firebaseService.currentUser!.uid)
        .get();
    
    myProviders.clear();
    for (var doc in querySnapshot.docs) {
      myProviders.add(ProviderModel.fromFirestore(doc));
    }
  }

  Future<void> _loadUpcomingBookings() async {
    upcomingBookings.clear();
    
    for (var provider in myProviders) {
      final querySnapshot = await _firebaseService.getProviderBookings(provider.id);
      for (var doc in querySnapshot.docs) {
        final booking = BookingModel.fromFirestore(doc);
        if (booking.bookingDate.isAfter(DateTime.now()) || 
            booking.bookingDate.day == DateTime.now().day) {
          upcomingBookings.add(booking);
        }
      }
    }
    
    upcomingBookings.sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
  }

  void _calculateEarnings() {
    double total = 0.0;
    for (var provider in myProviders) {
      // This is a simplified calculation
      // In a real app, you'd calculate based on completed bookings
      total += provider.pricePerHour * 8 * 30; // Assuming 8 hours/day, 30 days
    }
    totalEarnings.value = total;
  }

  void goToOwnerRegistration() {
    _clearRegistrationForm();
    Get.toNamed(AppRoutes.OWNER_REGISTRATION);
  }

  void goToAddChargingSlot() {
    _clearRegistrationForm();
    Get.toNamed(AppRoutes.ADD_CHARGING_SLOT);
  }

  void goToOwnerDashboard() {
    Get.toNamed(AppRoutes.OWNER_DASHBOARD);
  }

  void _clearRegistrationForm() {
    nameController.clear();
    addressController.clear();
    priceController.clear();
    selectedChargerType.value = 'slow';
    selectedDays.clear();
    startTime.value = '09:00';
    endTime.value = '18:00';
    selectedImages.clear();
    selectedDocuments.clear();
  }

  void toggleDay(String day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
  }

  void updateChargerType(String type) {
    selectedChargerType.value = type;
  }

  void updateStartTime(String time) {
    startTime.value = time;
  }

  void updateEndTime(String time) {
    endTime.value = time;
  }

  Future<void> pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      for (var image in images) {
        selectedImages.add(File(image.path));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images');
    }
  }

  Future<void> pickDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        for (var file in result.files) {
          selectedDocuments.add(File(file.path!));
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick documents');
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  void removeDocument(int index) {
    selectedDocuments.removeAt(index);
  }

  Future<void> submitProviderRegistration() async {
    if (!_validateRegistrationForm()) return;

    try {
      isSubmitting.value = true;
      
      // Upload images
      List<String> imageUrls = [];
      if (selectedImages.isNotEmpty) {
        imageUrls = await _firebaseService.uploadMultipleFiles(
          selectedImages,
          'providers/${_firebaseService.currentUser!.uid}/images',
        );
      }
      
      // Upload documents
      List<String> documentUrls = [];
      if (selectedDocuments.isNotEmpty) {
        documentUrls = await _firebaseService.uploadMultipleFiles(
          selectedDocuments,
          'providers/${_firebaseService.currentUser!.uid}/documents',
        );
      }
      
      // Create provider
      final provider = ProviderModel(
        id: '',
        userId: _firebaseService.currentUser!.uid,
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        latitude: 0.0, // In a real app, get from geocoding
        longitude: 0.0,
        chargerType: selectedChargerType.value,
        pricePerHour: double.parse(priceController.text),
        availableDays: selectedDays.map((day) => day.toLowerCase()).toList(),
        startTime: startTime.value,
        endTime: endTime.value,
        images: imageUrls,
        documents: documentUrls,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firebaseService.createProvider(provider.toFirestore());
      
      // Update user type
      await _firebaseService.updateUserDocument(
        _firebaseService.currentUser!.uid,
        {
          'userType': 'both',
          'updatedAt': DateTime.now(),
        },
      );
      
      Get.back();
      Get.snackbar(
        'Success',
        'Provider registration submitted for review',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      await _loadOwnerData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit registration');
    } finally {
      isSubmitting.value = false;
    }
  }

  bool _validateRegistrationForm() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter station name');
      return false;
    }
    if (addressController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter address');
      return false;
    }
    if (priceController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter price per hour');
      return false;
    }
    if (selectedDays.isEmpty) {
      Get.snackbar('Error', 'Please select available days');
      return false;
    }
    if (selectedImages.isEmpty) {
      Get.snackbar('Error', 'Please add at least one image');
      return false;
    }
    if (selectedDocuments.isEmpty) {
      Get.snackbar('Error', 'Please upload proof documents');
      return false;
    }
    
    try {
      double.parse(priceController.text);
    } catch (e) {
      Get.snackbar('Error', 'Please enter a valid price');
      return false;
    }
    
    return true;
  }

  Future<void> refreshData() async {
    await _loadOwnerData();
  }

  void editProvider(ProviderModel provider) {
    // Pre-fill form with existing data
    nameController.text = provider.name;
    addressController.text = provider.address;
    priceController.text = provider.pricePerHour.toString();
    selectedChargerType.value = provider.chargerType;
    selectedDays.value = provider.availableDays.map((day) => 
        day.substring(0, 1).toUpperCase() + day.substring(1)).toList();
    startTime.value = provider.startTime;
    endTime.value = provider.endTime;
    
    Get.toNamed(AppRoutes.EDIT_CHARGING_SLOT, arguments: provider);
  }

  Future<void> updateProvider(ProviderModel provider) async {
    if (!_validateRegistrationForm()) return;

    try {
      isSubmitting.value = true;
      
      // Upload new images if any
      List<String> imageUrls = List.from(provider.images);
      if (selectedImages.isNotEmpty) {
        final newImageUrls = await _firebaseService.uploadMultipleFiles(
          selectedImages,
          'providers/${_firebaseService.currentUser!.uid}/images',
        );
        imageUrls.addAll(newImageUrls);
      }
      
      // Upload new documents if any
      List<String> documentUrls = List.from(provider.documents);
      if (selectedDocuments.isNotEmpty) {
        final newDocumentUrls = await _firebaseService.uploadMultipleFiles(
          selectedDocuments,
          'providers/${_firebaseService.currentUser!.uid}/documents',
        );
        documentUrls.addAll(newDocumentUrls);
      }
      
      final updatedData = {
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'chargerType': selectedChargerType.value,
        'pricePerHour': double.parse(priceController.text),
        'availableDays': selectedDays.map((day) => day.toLowerCase()).toList(),
        'startTime': startTime.value,
        'endTime': endTime.value,
        'images': imageUrls,
        'documents': documentUrls,
        'updatedAt': DateTime.now(),
      };
      
      await _firebaseService.updateProvider(provider.id, updatedData);
      
      Get.back();
      Get.snackbar(
        'Success',
        'Provider updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      await _loadOwnerData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update provider');
    } finally {
      isSubmitting.value = false;
    }
  }
}