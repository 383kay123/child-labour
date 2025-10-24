import 'package:flutter/material.dart';
import 'package:human_rights_monitor/view/pages/community/community_list_screen.dart';
import 'package:human_rights_monitor/view/pages/farmers/farmer_list_screen.dart';

import '../home/home.dart';
import '../profile/profile.dart';

class ScreenWrapper extends StatefulWidget {
  const ScreenWrapper({super.key});

  @override
  State<ScreenWrapper> createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends State<ScreenWrapper> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    Homepage(),
    FarmerListScreen(),
    CommunityListScreen(),
    ProfileScreen(),
  ];

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onItemTapped(int selectedIndex) {
    _pageController.animateToPage(
      selectedIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: theme.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed, // keeps labels always visible
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: "Farmers",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: "Communities",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
