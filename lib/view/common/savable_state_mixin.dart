import 'dart:async';
import 'package:flutter/material.dart';

/// A mixin that provides save functionality for form states
mixin SavableState<T extends StatefulWidget> on State<T> {
  /// Saves the form data
  /// 
  /// [farmId] - The ID to associate with the saved data
  /// Returns true if save was successful, false otherwise
  Future<bool> saveData(String farmId);

  /// Validates the form data
  /// 
  /// [silent] - If true, won't show error messages
  /// Returns true if validation passes, false otherwise
  bool validateForm({bool silent = false}) {
    // Default implementation that can be overridden
    return true;
  }
}
