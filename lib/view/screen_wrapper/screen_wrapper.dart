import 'package:flutter/material.dart';
import 'package:human_rights_monitor/view/pages/communities/community_list_screen.dart';
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
    FarmersListScreen(),
    DistrictsListScreen(),
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
    
    // Define a custom color scheme for the bottom navigation bar
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color selectedColor = theme.primaryColor;
    final Color unselectedColor = isDarkMode 
        ? Colors.grey.shade400 
        : Colors.grey.shade600;

    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: selectedColor,
          unselectedItemColor: unselectedColor,
          selectedLabelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 0 
                    ? Icons.home_rounded 
                    : Icons.home_outlined,
                size: 24,
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home_rounded,
                  size: 24,
                  color: selectedColor,
                ),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 1 
                    ? Icons.agriculture_rounded 
                    : Icons.agriculture_outlined,
                size: 24,
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.agriculture_rounded,
                  size: 24,
                  color: selectedColor,
                ),
              ),
              label: "Farmers",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 2 
                    ? Icons.location_city_rounded 
                    : Icons.location_city_outlined,
                size: 24,
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_city_rounded,
                  size: 24,
                  color: selectedColor,
                ),
              ),
              label: "Districts",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 3 
                    ? Icons.person_rounded 
                    : Icons.person_outlined,
                size: 24,
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 24,
                  color: selectedColor,
                ),
              ),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}