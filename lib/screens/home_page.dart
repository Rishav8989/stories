import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/screens/home%20screen/account_page.dart';
import 'package:stories/screens/home%20screen/create_page.dart';
import 'package:stories/utils/theme/theme_controller.dart';
import 'package:stories/screens/home%20screen/discover_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {    
    final ThemeController themeController = Get.find();
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          body: IndexedStack(
            index: controller.tabIndex,
            children: const [
              DiscoverPage(),
              CreatePage(),
              AccountPage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            unselectedItemColor: Theme.of(context).unselectedWidgetColor,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            onTap: controller.changeTabIndex,
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
