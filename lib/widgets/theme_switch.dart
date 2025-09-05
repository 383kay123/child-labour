// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../theme/theme_provider.dart';
//
// class ThemeSwitch extends StatelessWidget {
//   const ThemeSwitch({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(
//           Icons.light_mode,
//           color: themeProvider.isDarkMode ? Colors.grey : Colors.amber,
//         ),
//         const SizedBox(width: 8),
//         Switch(
//           value: themeProvider.isDarkMode,
//           onChanged: (value) => themeProvider.toggleTheme(value),
//           activeColor: Colors.green,
//         ),
//         const SizedBox(width: 8),
//         Icon(
//           Icons.dark_mode,
//           color: themeProvider.isDarkMode ? Colors.blue : Colors.grey,
//         ),
//       ],
//     );
//   }
// }
