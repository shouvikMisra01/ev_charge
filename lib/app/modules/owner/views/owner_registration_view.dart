import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/owner_controller.dart';

class OwnerRegistrationView extends GetView<OwnerController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Provider'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.ev_station,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Share Your Charging Station',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Turn your garage into a source of income by sharing your EV charging station with others.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Benefits
            const Text(
              'Why Become a Provider?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            _buildBenefitItem(
              Icons.currency_rupee,
              'Earn Extra Income',
              'Make money from your unused charging capacity',
            ),
            _buildBenefitItem(
              Icons.eco,
              'Support Green Energy',
              'Help accelerate EV adoption in your community',
            ),
            _buildBenefitItem(
              Icons.schedule,
              'Flexible Schedule',
              'Set your own availability and pricing',
            ),
            _buildBenefitItem(
              Icons.security,
              'Safe & Secure',
              'All users are verified and transactions are protected',
            ),
            
            const SizedBox(height: 24),
            
            // Requirements
            const Text(
              'Requirements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequirementItem('✓ Own or have access to an EV charging station'),
                    _buildRequirementItem('✓ Valid proof of ownership/permission'),
                    _buildRequirementItem('✓ Safe and accessible location'),
                    _buildRequirementItem('✓ Reliable power supply'),
                    _buildRequirementItem('✓ Available for at least 4 hours per day'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // How it works
            const Text(
              'How It Works',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            _buildStepItem(
              '1',
              'Register',
              'Fill out the application form with your station details',
            ),
            _buildStepItem(
              '2',
              'Verification',
              'Our team reviews your application (1-2 business days)',
            ),
            _buildStepItem(
              '3',
              'Go Live',
              'Start accepting bookings and earning money',
            ),
            
            const SizedBox(height: 32),
            
            // CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.goToAddChargingSlot,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'By proceeding, you agree to our Terms of Service and Provider Agreement.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
          child: Icon(icon, color: Get.theme.primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(description),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildStepItem(String number, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Get.theme.primaryColor,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(description),
      ),
    );
  }
}