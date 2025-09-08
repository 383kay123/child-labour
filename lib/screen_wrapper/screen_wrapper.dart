// import 'package:flutter/material.dart';
//
// class ScreenWrapper extends StatefulWidget {
//   final Widget child;
//   final String? title;
//   final List<Widget>? actions;
//   final Widget? floatingActionButton;
//   final bool showAppBar;
//   final Color? backgroundColor;
//   final List<BottomNavigationBarItem>? bottomNavItems;
//   final int currentIndex;
//   final ValueChanged<int>? onNavItemTapped;
//   final bool showBottomNavBar;
//
//   const ScreenWrapper({
//     super.key,
//     required this.child,
//     this.title,
//     this.actions,
//     this.floatingActionButton,
//     this.showAppBar = true,
//     this.backgroundColor,
//     this.bottomNavItems,
//     this.currentIndex = 0,
//     this.onNavItemTapped,
//     this.showBottomNavBar = false,
//   });
//
//   @override
//   State<ScreenWrapper> createState() => _ScreenWrapperState();
// }
//
// class _ScreenWrapperState extends State<ScreenWrapper> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
//       appBar: widget.showAppBar
//           ? AppBar(
//               title: widget.title != null ? Text(widget.title!) : null,
//               centerTitle: true,
//               actions: widget.actions,
//               elevation: 0,
//             )
//           : null,
//       body: SafeArea(
//         child: widget.child,
//       ),
//       floatingActionButton: widget.floatingActionButton,
//       bottomNavigationBar:
//           widget.showBottomNavBar && widget.bottomNavItems != null
//               ? BottomNavigationBar(
//                   items: widget.bottomNavItems!,
//                   currentIndex: widget.currentIndex,
//                   onTap: widget.onNavItemTapped,
//                   type: BottomNavigationBarType.fixed,
//                   selectedItemColor: Theme.of(context).primaryColor,
//                   unselectedItemColor: Colors.grey,
//                   showSelectedLabels: true,
//                   showUnselectedLabels: true,
//                   elevation: 8,
//                 )
//               : null,
//     );
//   }
// }
