import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/api/auth/auth_api.dart';
import 'package:human_rights_monitor/controller/models/auth/user_model.dart';
import 'package:human_rights_monitor/controller/providers/auth_provider.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/staff_repo.dart';
import 'package:human_rights_monitor/view/sync/sync_page.dart';
import 'package:provider/provider.dart';

import '../screen_wrapper/screen_wrapper.dart';

class LoginController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;
  String? _errorMessage;

  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  @override
  void dispose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void toggleIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> handleLogin(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    try {
      clearError();
      toggleIsLoading();

      final staff = await AuthService.login(
        staffId: phoneNumberController.text,
        password: passwordController.text,
      );
      
      if (staff != null && staff.id.toString() != "") {
        try {
          // Get the staff details from the database
          final staffRepo = StaffRepository();
          final staffDetails = await staffRepo.getStaffByStaffId(phoneNumberController.text);
          
          // Update the auth provider with staff details
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          
          if (staffDetails != null) {
            // If we have staff details from the database, use them
            final user = UserModel(
              id: staffDetails.id,
              firstName: staffDetails.firstName,
              lastName: staffDetails.lastName,
              gender: staffDetails.gender,
              contact: staffDetails.contact,
              designation: staffDetails.designation,
              emailAddress: staffDetails.emailAddress,
              staffid: staffDetails.staffId,
              assignedDistricts: staffDetails.assignedDistricts,
            );
            authProvider.setUser(user);
            debugPrint('User set with first name from database: ${user.firstName}');
          } else {
            // If no staff details found, use the staff object from login
            debugPrint('Using staff data from login response');
            authProvider.setUser(staff);
            debugPrint('User set with first name from login: ${staff.firstName}');
          }
        } catch (e) {
          debugPrint('Error fetching staff details: $e');
          // If there's an error, use the staff object from login
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          authProvider.setUser(staff);
          debugPrint('User set with first name after error: ${staff.firstName}');
        }
      
      toggleIsLoading();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SyncPage()),
        );
      }
      return true;
    }
    toggleIsLoading();
    _errorMessage = "Invalid credentials. Please try again.";
    notifyListeners();
    return false;
  } catch (e) {
    toggleIsLoading();
    _errorMessage = e.toString().replaceAll('Exception: ', '');
    notifyListeners();
    debugPrint("Login error: $_errorMessage");
    return false;
  }
}
}
