import 'package:flutter/foundation.dart';
import '../../controller/cache/cache_service.dart';
import '../models/auth/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  UserModel? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _loadCachedUser();
  }

  Future<void> _loadCachedUser() async {
    try {
      final cachedUser = await StaffCache.getStaff();
      if (cachedUser != null) {
        _user = cachedUser;
        _isLoggedIn = true;
      }
    } catch (e) {
      debugPrint('Error loading cached user: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setUser(UserModel user) async {
    _user = user;
    _isLoggedIn = true;
    await StaffCache.saveStaff(user);
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _isLoggedIn = false;
    await StaffCache.clearStaff();
    notifyListeners();
  }
}
