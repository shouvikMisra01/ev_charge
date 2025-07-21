import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../user/views/user_home_view.dart';
import '../../owner/views/owner_home_view.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [
            UserHomeView(),
            if (controller.canShowOwnerTab) OwnerHomeView(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Find Stations',
            ),
            if (controller.canShowOwnerTab)
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_work),
                label: 'My Stations',
              ),
          ],
        ),
      );
    });
  }
}