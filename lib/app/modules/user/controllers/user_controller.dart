import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/services/firebase_service.dart';
import '../../../data/models/provider_model.dart';
import '../../../routes/app_routes.dart';

class UserController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  
  GoogleMapController? mapController;
  final currentPosition = Rxn<Position>();
  final providers = <ProviderModel>[].obs;
  final filteredProviders = <ProviderModel>[].obs;
  final markers = <Marker>{}.obs;
  final isLoading = false.obs;
  final selectedProvider = Rxn<ProviderModel>();
  
  // Filter variables
  final selectedChargerType = 'all'.obs;
  final maxPrice = 100.0.obs;
  final selectedTimeSlot = 'any'.obs;
  
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
    _loadProviders();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Error', 'Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Error', 'Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Error', 'Location permissions are permanently denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      currentPosition.value = position;
      
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _loadProviders() async {
    try {
      isLoading.value = true;
      final querySnapshot = await _firebaseService.getProviders();
      
      providers.clear();
      for (var doc in querySnapshot.docs) {
        providers.add(ProviderModel.fromFirestore(doc));
      }
      
      _applyFilters();
      _updateMapMarkers();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load charging stations');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    filteredProviders.clear();
    
    for (var provider in providers) {
      bool matchesChargerType = selectedChargerType.value == 'all' || 
                               provider.chargerType == selectedChargerType.value;
      bool matchesPrice = provider.pricePerHour <= maxPrice.value;
      bool matchesSearch = searchController.text.isEmpty ||
                          provider.name.toLowerCase().contains(searchController.text.toLowerCase()) ||
                          provider.address.toLowerCase().contains(searchController.text.toLowerCase());
      
      if (matchesChargerType && matchesPrice && matchesSearch) {
        filteredProviders.add(provider);
      }
    }
  }

  void _updateMapMarkers() {
    markers.clear();
    
    for (var provider in filteredProviders) {
      markers.add(
        Marker(
          markerId: MarkerId(provider.id),
          position: LatLng(provider.latitude, provider.longitude),
          infoWindow: InfoWindow(
            title: provider.name,
            snippet: '₹${provider.pricePerHour}/hour - ${provider.chargerType.toUpperCase()}',
            onTap: () => selectProvider(provider),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            provider.chargerType == 'fast' ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }
  }

  void selectProvider(ProviderModel provider) {
    selectedProvider.value = provider;
    _showProviderBottomSheet();
  }

  void _showProviderBottomSheet() {
    if (selectedProvider.value == null) return;
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedProvider.value!.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              selectedProvider.value!.address,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  Icons.flash_on,
                  selectedProvider.value!.chargerType.toUpperCase(),
                  Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.currency_rupee,
                  '${selectedProvider.value!.pricePerHour}/hour',
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Available: ${selectedProvider.value!.availableDays.join(', ')}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Time: ${selectedProvider.value!.startTime} - ${selectedProvider.value!.endTime}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(AppRoutes.BOOKING, arguments: selectedProvider.value);
                },
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentPosition.value != null) {
      controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(currentPosition.value!.latitude, currentPosition.value!.longitude),
        ),
      );
    }
  }

  void updateChargerTypeFilter(String type) {
    selectedChargerType.value = type;
    _applyFilters();
    _updateMapMarkers();
  }

  void updatePriceFilter(double price) {
    maxPrice.value = price;
    _applyFilters();
    _updateMapMarkers();
  }

  void updateTimeSlotFilter(String timeSlot) {
    selectedTimeSlot.value = timeSlot;
    _applyFilters();
    _updateMapMarkers();
  }

  void searchProviders() {
    _applyFilters();
    _updateMapMarkers();
  }

  void showFilters() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Charger Type Filter
            const Text('Charger Type', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              children: ['all', 'slow', 'fast', 'ac', 'dc'].map((type) {
                return FilterChip(
                  label: Text(type == 'all' ? 'All' : type.toUpperCase()),
                  selected: selectedChargerType.value == type,
                  onSelected: (selected) => updateChargerTypeFilter(type),
                );
              }).toList(),
            )),
            
            const SizedBox(height: 20),
            
            // Price Filter
            const Text('Max Price per Hour', style: TextStyle(fontWeight: FontWeight.w500)),
            Obx(() => Slider(
              value: maxPrice.value,
              min: 0,
              max: 200,
              divisions: 20,
              label: '₹${maxPrice.value.round()}',
              onChanged: updatePriceFilter,
            )),
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void goToProfile() {
    Get.toNamed(AppRoutes.PROFILE);
  }

  void goToBookingsHistory() {
    Get.toNamed(AppRoutes.BOOKINGS_HISTORY);
  }
}