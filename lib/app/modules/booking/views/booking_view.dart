import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/booking_controller.dart';

class BookingView extends GetView<BookingController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Charging Slot'),
      ),
      body: Obx(() {
        if (controller.selectedProvider.value == null) {
          return const Center(
            child: Text('No provider selected'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.selectedProvider.value!.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.selectedProvider.value!.address,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.flash_on,
                            controller.selectedProvider.value!.chargerType.toUpperCase(),
                            Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            Icons.currency_rupee,
                            '${controller.selectedProvider.value!.pricePerHour}/hour',
                            Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Date Selection
              const Text(
                'Select Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CalendarDatePicker(
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        onDateChanged: controller.selectDate,
                      ),
                      if (controller.selectedDate.value != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Selected: ${controller.formatDate(controller.selectedDate.value!)}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Time Selection
              const Text(
                'Select Time Slot',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Time',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.timeSlots.map((time) {
                          final isSelected = controller.selectedStartTime.value == time;
                          final isAvailable = controller.isTimeSlotAvailable(time);
                          
                          return FilterChip(
                            label: Text(time),
                            selected: isSelected,
                            onSelected: isAvailable ? (selected) {
                              if (selected) controller.selectStartTime(time);
                            } : null,
                            backgroundColor: isAvailable ? null : Colors.grey[300],
                          );
                        }).toList(),
                      ),
                      
                      if (controller.selectedStartTime.value.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'End Time',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.timeSlots.map((time) {
                            final startIndex = controller.timeSlots.indexOf(controller.selectedStartTime.value);
                            final currentIndex = controller.timeSlots.indexOf(time);
                            final isSelectable = currentIndex > startIndex;
                            final isSelected = controller.selectedEndTime.value == time;
                            
                            return FilterChip(
                              label: Text(time),
                              selected: isSelected,
                              onSelected: isSelectable ? (selected) {
                                if (selected) controller.selectEndTime(time);
                              } : null,
                              backgroundColor: isSelectable ? null : Colors.grey[300],
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Booking Summary
              if (controller.totalAmount.value > 0) ...[
                const Text(
                  'Booking Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSummaryRow('Date', controller.selectedDate.value != null 
                            ? controller.formatDate(controller.selectedDate.value!) 
                            : ''),
                        _buildSummaryRow('Time', 
                            '${controller.selectedStartTime.value} - ${controller.selectedEndTime.value}'),
                        _buildSummaryRow('Duration', _calculateDuration()),
                        _buildSummaryRow('Rate', '₹${controller.selectedProvider.value!.pricePerHour}/hour'),
                        const Divider(),
                        _buildSummaryRow(
                          'Total Amount', 
                          '₹${controller.totalAmount.value.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Book Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.confirmBooking,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Book for ₹${controller.totalAmount.value.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
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

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDuration() {
    if (controller.selectedStartTime.value.isEmpty || 
        controller.selectedEndTime.value.isEmpty) {
      return '';
    }
    
    final startIndex = controller.timeSlots.indexOf(controller.selectedStartTime.value);
    final endIndex = controller.timeSlots.indexOf(controller.selectedEndTime.value);
    
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      final hours = endIndex - startIndex;
      return '$hours hour${hours > 1 ? 's' : ''}';
    }
    
    return '';
  }
}