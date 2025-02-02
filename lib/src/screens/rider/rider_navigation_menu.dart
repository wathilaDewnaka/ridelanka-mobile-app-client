import 'package:client/src/screens/rider/history_tab.dart';
import 'package:client/src/screens/rider/home_tab.dart';
import 'package:client/src/screens/rider/notifications_tab.dart';
import 'package:client/src/screens/rider/profile_tab.dart';
import 'package:flutter/material.dart';

class RiderNavigationMenu extends StatefulWidget {
  const RiderNavigationMenu({super.key});

  static const String id = "ridermainpage";

  @override
  State<RiderNavigationMenu> createState() => _RiderNavigationMenuState();
}

class _RiderNavigationMenuState extends State<RiderNavigationMenu>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  int selectedIndex = 0;

  void onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [HomeTab(), HistoryTab(), NotificationsTab(), ProfileTab()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_add_outlined),
            label: "Notification",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        currentIndex: selectedIndex,
        unselectedItemColor: Colors.grey[800],
        selectedItemColor: const Color(0xFF0051ED),
        showUnselectedLabels: true,
        showSelectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800), 
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        iconSize: 30,
        type: BottomNavigationBarType.fixed,
        onTap: onItemClicked,
      ),
    );
  }
}
