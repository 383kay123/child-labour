import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/api/auth/auth_api.dart';
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
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      toggleIsLoading();

      final staff = await AuthService.login(
        staffId: phoneNumberController.text,
        password: passwordController.text,
      );
      toggleIsLoading();

      if (staff != null && staff.id.toString() != "") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenWrapper(),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint("THE LOGIN ERROR IS === $e");
      debugPrint("THE STACK TRACE ERROR IS === $stackTrace");
    }
  }
}
