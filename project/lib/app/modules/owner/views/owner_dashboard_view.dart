import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/owner_controller.dart';

class OwnerDashboardView extends GetView<OwnerController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildOverviewCard(
                      'Total Stations',
                      controller.myProviders.length.toString(),
                      Icons.ev_station,
                      Colors.blue,
                    ),
                    _buildOverviewCard(
                      'Active Stations',
                      controller.myProviders.where((p) => p.status == 'verified').length.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildOverviewCard(
                      'Total Bookings',
                      controller.upcomingBookings.length.toString(),
                      Icons.schedule,
                      Colors.orange,
                    ),
                    _buildOverviewCard(
                      'Monthly Earnings',
                      '₹${controller.totalEarnings.value.toStringAsFixed(0)}',
                      Icons.currency_rupee,
                      Colors.purple,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Recent Bookings
                Row(
                  children: [
                    const Text(
                      'Recent Bookings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Navigate to all bookings
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                if (controller.upcomingBookings.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text('No recent bookings'),
                      ),
                    ),
                  )
                else
                  ...controller.upcomingBookings.take(3).map((booking) => 
                    _buildBookingCard(booking)).toList(),
                
                const SizedBox(height: 24),
                
                // Station Performance
                const Text(
                  'Station Performance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                if (controller.myProviders.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text('No stations to show performance'),
                      ),
                    ),
                  )
                else
                  ...controller.myProviders.map((provider) => 
                    _buildStationPerformanceCard(provider)).toList(),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: InkWell(
                          onTap: controller.goToAddChargingSlot,
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(Icons.add_circle, size: 32, color: Colors.blue),
                                SizedBox(height: 8),
                                Text(
                                  'Add Station',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            // Navigate to earnings
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(Icons.analytics, size: 32, color: Colors.green),
                                SizedBox(height: 8),
                                Text(
                                  'View Analytics',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(Icons.schedule, color: Colors.blue),
        ),
        title: Text(booking.providerName),
        subtitle: Text(
          '${booking.startTime} - ${booking.endTime}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${booking.totalAmount}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              '${booking.bookingDate.day}/${booking.bookingDate.month}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationPerformanceCard(provider) {
    // Mock data for demonstration
    final bookingsCount = 12;
    final rating = 4.5;
    final utilization = 75;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    provider.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(provider.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetric('Bookings', bookingsCount.toString()),
                ),
                Expanded(
                  child: _buildMetric('Rating', rating.toString()),
                ),
                Expanded(
                  child: _buildMetric('Utilization', '$utilization%'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'verified':
        color = Colors.green;
        label = 'Active';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
}