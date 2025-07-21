import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: controller.showEditProfileDialog,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.currentUser.value == null) {
          return const Center(
            child: Text('Failed to load profile'),
          );
        }

        final user = controller.currentUser.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildUserTypeChip(user.userType),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Profile Information
              Card(
                child: Column(
                  children: [
                    _buildProfileItem(
                      Icons.person,
                      'Name',
                      user.name,
                    ),
                    _buildProfileItem(
                      Icons.email,
                      'Email',
                      user.email,
                    ),
                    _buildProfileItem(
                      Icons.phone,
                      'Phone',
                      user.phone.isNotEmpty ? user.phone : 'Not provided',
                    ),
                    _buildProfileItem(
                      Icons.calendar_today,
                      'Member Since',
                      _formatDate(user.createdAt),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Actions
              Card(
                child: Column(
                  children: [
                    _buildActionItem(
                      Icons.history,
                      'My Bookings',
                      'View your booking history',
                      controller.goToBookingsHistory,
                    ),
                    if (user.userType == 'user')
                      _buildActionItem(
                        Icons.home_work,
                        'Become a Provider',
                        'Share your charging station',
                        controller.goToOwnerRegistration,
                      ),
                    _buildActionItem(
                      Icons.dark_mode,
                      'Dark Mode',
                      'Toggle dark/light theme',
                      controller.toggleTheme,
                      trailing: Switch(
                        value: controller.isDarkMode.value,
                        onChanged: (_) => controller.toggleTheme(),
                      ),
                    ),
                    _buildActionItem(
                      Icons.help,
                      'Help & Support',
                      'Get help and support',
                      () {
                        // Navigate to help
                      },
                    ),
                    _buildActionItem(
                      Icons.info,
                      'About',
                      'App version and info',
                      () {
                        // Show about dialog
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Sign Out Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.showSignOutDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // App Info
              Text(
                'ChargeAtHome v1.0.0',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUserTypeChip(String userType) {
    Color color;
    String label;
    
    switch (userType) {
      case 'provider':
        color = Colors.green;
        label = 'Provider';
        break;
      case 'both':
        color = Colors.purple;
        label = 'User & Provider';
        break;
      default:
        color = Colors.blue;
        label = 'User';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  Widget _buildActionItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}