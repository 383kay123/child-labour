import 'package:flutter/material.dart';
import 'package:human_rights_monitor/view/sync/sync_page.dart';

import '../screen_wrapper/screen_wrapper.dart';


class LoginController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  toggleIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  Future<void> handleLogin(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    toggleIsLoading();



    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SyncPage()),
    );

  }
}