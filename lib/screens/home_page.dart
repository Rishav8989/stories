import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/screens/home%20screen/account_page.dart';
import 'package:stories/screens/home%20screen/create_page.dart';
import 'package:stories/screens/home%20screen/discover_page.dart';
import 'package:stories/controller/discover_page_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {    
    // Add controller binding with lazy loading
    Get.lazyPut(() => DiscoverController(), fenix: true);
    
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller.pageController,
            onPageChanged: controller.changeTabIndex,
            children: const [
              DiscoverPage(),
              CreatePage(),
              AccountPage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            unselectedItemColor: Theme.of(context).unselectedWidgetColor,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            onTap: controller.animateToPage,
            currentIndex: controller.tabIndex,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,            
            elevation: 0,
            items: [
              _bottomNavigationBarItem(
                icon: Icons.explore,
                label: 'Discover',
              ),
              _bottomNavigationBarItem(
                icon: Icons.add_box,
                label: 'Create',
              ),
              _bottomNavigationBarItem(
                icon: Icons.person,
                label: 'Account',
              ),
            ],
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _bottomNavigationBarItem({required IconData icon, required String label}) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }
}

class HomeController extends GetxController {
  var tabIndex = 0;
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void animateToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void changeTabIndex(int index) {
    tabIndex = index;
    update();
  }

  String getTitle() {
    switch (tabIndex) {
      case 0:
        return 'Discover';
      case 1:
        return 'Create';
      case 2:
        return 'Account';
      default:
        return 'Stories App';
    }
  }
}
