// Import necessary Dart libraries for networking and async operations
import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:async';

class ConnectionVerify {
  // The domain we'll use to test internet connectivity (globally available)
  static const String _testAddress = 'example.com';

  // Maximum time we'll wait for a connection response (5 seconds)
  static const int _timeoutSeconds = 5;

  // Minimum acceptable connection speed (50 kilobytes per second)
  static const int _minSpeedKbps = 50;

  /// Checks if internet connection is available and meets minimum speed requirements
  /// Returns [true] if connection is good, [false] otherwise
  static Future<bool> connectionIsAvailable() async {
    try {
      // Create a stopwatch to measure how long the connection test takes
      final stopwatch = Stopwatch()..start();

      // Try to perform a DNS lookup with a timeout
      // If it takes longer than _timeoutSeconds, throw TimeoutException
      final result = await InternetAddress.lookup(_testAddress)
          .timeout(const Duration(seconds: _timeoutSeconds),
          onTimeout: () => throw TimeoutException('Connection timed out'));

      // Stop the stopwatch since we got a response
      stopwatch.stop();

      // Calculate approximate connection speed based on response time
      final speedKbps = _calculateConnectionSpeed(stopwatch.elapsedMilliseconds);

      // Check if we got valid DNS results
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // If connection speed is below our minimum threshold
        if (speedKbps < _minSpeedKbps) {
          debugPrint('Connection is too slow: $speedKbps KB/s');
          return true;
        }
        // Connection is good - print speed and return true
        debugPrint('Connection speed: $speedKbps KB/s');
        return true;
      }
      // If we got empty results
      return false;
    } on SocketException catch (_) {
      // This exception occurs when there's no network connection
      return false;
    } on TimeoutException catch (_) {
      // This occurs when the connection is too slow
      return false;
    } catch (e) {
      // Catch any other unexpected errors
      debugPrint('Connection check error: $e');
      return false;
    }
  }

  /// Estimates connection speed based on how long a DNS lookup took
  /// [milliseconds] - The time taken for the DNS lookup
  /// Returns estimated speed in kilobytes per second
  static double _calculateConnectionSpeed(int milliseconds) {
    // We assume the DNS request transferred about 1KB of data
    const assumedDataSize = 1; // KB

    // Convert milliseconds to seconds
    final seconds = milliseconds / 1000;

    // Calculate speed (data size / time taken)
    return assumedDataSize / seconds;
  }

  /// Checks if the connection quality is good enough for the app's needs
  /// Returns [true] if connection is good (fast and reliable), [false] otherwise
  static Future<bool> checkConnectionQuality() async {
    try {
      // Start measuring time
      final stopwatch = Stopwatch()..start();

      // Try DNS lookup with timeout
      final result = await InternetAddress.lookup(_testAddress)
          .timeout(const Duration(seconds: _timeoutSeconds),
          onTimeout: () => throw TimeoutException('Connection timed out'));

      // Stop timing
      stopwatch.stop();

      // Calculate speed
      final speedKbps = _calculateConnectionSpeed(stopwatch.elapsedMilliseconds);

      // If we got no results or empty address
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        return false;
      }

      // Consider connection good if:
      // 1. Response time is under 1 second AND
      // 2. Speed is above minimum threshold
      return stopwatch.elapsedMilliseconds < 1000 && speedKbps >= _minSpeedKbps;
    } catch (_) {
      // Any error means connection is not good
      return false;
    }
  }
}