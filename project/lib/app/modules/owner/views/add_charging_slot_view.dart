import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/owner_controller.dart';

class AddChargingSlotView extends GetView<OwnerController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Charging Station'),
      ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: 'Station Name',
                prefixIcon: Icon(Icons.ev_station),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: controller.addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: controller.priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price per Hour (₹)',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Charger Type
            const Text(
              'Charger Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              children: controller.chargerTypes.map((type) {
                return Obx(() => FilterChip(
                  label: Text(type.toUpperCase()),
                  selected: controller.selectedChargerType.value == type,
                  onSelected: (selected) => controller.updateChargerType(type),
                ));
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Available Days
            const Text(
              'Available Days',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              children: controller.weekDays.map((day) {
                return Obx(() => FilterChip(
                  label: Text(day.substring(0, 3)),
                  selected: controller.selectedDays.contains(day),
                  onSelected: (selected) => controller.toggleDay(day),
                ));
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Time Slots
            const Text(
              'Available Hours',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: const Text('Start Time'),
                      subtitle: Obx(() => Text(controller.startTime.value)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _showTimePicker(context, true),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: const Text('End Time'),
                      subtitle: Obx(() => Text(controller.endTime.value)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _showTimePicker(context, false),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Images
            const Text(
              'Station Images',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (controller.selectedImages.isEmpty)
                      Column(
                        children: [
                          Icon(Icons.image, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          const Text('No images selected'),
                          const SizedBox(height: 8),
                        ],
                      )
                    else
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.selectedImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      controller.selectedImages[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => controller.removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    
                    ElevatedButton.icon(
                      onPressed: controller.pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Add Images'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Documents
            const Text(
              'Proof Documents',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (controller.selectedDocuments.isEmpty)
                      Column(
                        children: [
                          Icon(Icons.description, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          const Text('No documents selected'),
                          const SizedBox(height: 8),
                        ],
                      )
                    else
                      ...controller.selectedDocuments.asMap().entries.map((entry) {
                        int index = entry.key;
                        var doc = entry.value;
                        return ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(doc.path.split('/').last),
                          trailing: IconButton(
                            onPressed: () => controller.removeDocument(index),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        );
                      }).toList(),
                    
                    ElevatedButton.icon(
                      onPressed: controller.pickDocuments,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Documents'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isSubmitting.value 
                    ? null 
                    : controller.submitProviderRegistration,
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit for Review'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Note: Your station will be reviewed by our team before going live. This usually takes 1-2 business days.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )),
    );
  }

  void _showTimePicker(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (isStartTime) {
        controller.updateStartTime(timeString);
      } else {
        controller.updateEndTime(timeString);
      }
    }
  }
}