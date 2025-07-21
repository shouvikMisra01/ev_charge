import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/services/firebase_service.dart';
import '../../../data/models/provider_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../routes/app_routes.dart';

class BookingController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  
  final selectedProvider = Rxn<ProviderModel>();
  final selectedDate = Rxn<DateTime>();
  final selectedStartTime = ''.obs;
  final selectedEndTime = ''.obs;
  final totalAmount = 0.0.obs;
  final isLoading = false.obs;
  final userBookings = <BookingModel>[].obs;
  
  final List<String> timeSlots = [
    '09:00', '10:00', '11:00', '12:00', '13:00', '14:00',
    '15:00', '16:00', '17:00', '18:00', '19:00', '20:00'
  ];

  @override
  void onInit() {
    super.onInit();
    
    // Get provider from arguments
    if (Get.arguments != null && Get.arguments is ProviderModel) {
      selectedProvider.value = Get.arguments as ProviderModel;
    }
    
    _loadUserBookings();
  }

  Future<void> _loadUserBookings() async {
    try {
      isLoading.value = true;
      if (_firebaseService.currentUser != null) {
        final querySnapshot = await _firebaseService.getUserBookings(
          _firebaseService.currentUser!.uid,
        );
        
        userBookings.clear();
        for (var doc in querySnapshot.docs) {
          userBookings.add(BookingModel.fromFirestore(doc));
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bookings');
    } finally {
      isLoading.value = false;
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    _calculateAmount();
  }

  void selectStartTime(String time) {
    selectedStartTime.value = time;
    
    // Auto-select end time (1 hour later)
    final startIndex = timeSlots.indexOf(time);
    if (startIndex != -1 && startIndex < timeSlots.length - 1) {
      selectedEndTime.value = timeSlots[startIndex + 1];
    }
    
    _calculateAmount();
  }

  void selectEndTime(String time) {
    selectedEndTime.value = time;
    _calculateAmount();
  }

  void _calculateAmount() {
    if (selectedStartTime.value.isEmpty || 
        selectedEndTime.value.isEmpty || 
        selectedProvider.value == null) {
      totalAmount.value = 0.0;
      return;
    }
    
    final startIndex = timeSlots.indexOf(selectedStartTime.value);
    final endIndex = timeSlots.indexOf(selectedEndTime.value);
    
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      final hours = endIndex - startIndex;
      totalAmount.value = hours * selectedProvider.value!.pricePerHour;
    } else {
      totalAmount.value = 0.0;
    }
  }

  Future<void> confirmBooking() async {
    if (!_validateBooking()) return;

    try {
      isLoading.value = true;
      
      final booking = BookingModel(
        id: '',
        userId: _firebaseService.currentUser!.uid,
        providerId: selectedProvider.value!.id,
        providerName: selectedProvider.value!.name,
        providerAddress: selectedProvider.value!.address,
        bookingDate: selectedDate.value!,
        startTime: selectedStartTime.value,
        endTime: selectedEndTime.value,
        totalAmount: totalAmount.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firebaseService.createBooking(booking.toFirestore());
      
      Get.offNamed(AppRoutes.BOOKING_CONFIRMATION, arguments: booking);
      
      Get.snackbar(
        'Success',
        'Booking confirmed successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to create booking');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateBooking() {
    if (selectedProvider.value == null) {
      Get.snackbar('Error', 'No provider selected');
      return false;
    }
    if (selectedDate.value == null) {
      Get.snackbar('Error', 'Please select a date');
      return false;
    }
    if (selectedStartTime.value.isEmpty) {
      Get.snackbar('Error', 'Please select start time');
      return false;
    }
    if (selectedEndTime.value.isEmpty) {
      Get.snackbar('Error', 'Please select end time');
      return false;
    }
    if (totalAmount.value <= 0) {
      Get.snackbar('Error', 'Invalid booking duration');
      return false;
    }
    
    // Check if date is not in the past
    if (selectedDate.value!.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      Get.snackbar('Error', 'Cannot book for past dates');
      return false;
    }
    
    return true;
  }

  Future<void> cancelBooking(BookingModel booking) async {
    try {
      await _firebaseService.updateBooking(booking.id, {
        'status': 'cancelled',
        'updatedAt': DateTime.now(),
      });
      
      await _loadUserBookings();
      
      Get.snackbar(
        'Success',
        'Booking cancelled successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel booking');
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String formatTime(String time) {
    return time;
  }

  bool isTimeSlotAvailable(String time) {
    // In a real app, check against existing bookings
    return true;
  }

  List<BookingModel> get upcomingBookings {
    return userBookings.where((booking) => 
      booking.bookingDate.isAfter(DateTime.now()) &&
      booking.status != 'cancelled'
    ).toList();
  }

  List<BookingModel> get pastBookings {
    return userBookings.where((booking) => 
      booking.bookingDate.isBefore(DateTime.now()) ||
      booking.status == 'completed'
    ).toList();
  }

  void goToBookingDetails(BookingModel booking) {
    // Navigate to booking details
  }

  Future<void> refreshBookings() async {
    await _loadUserBookings();
  }
}