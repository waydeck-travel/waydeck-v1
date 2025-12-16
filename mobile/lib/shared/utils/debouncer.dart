import 'dart:async';
import 'package:flutter/foundation.dart';

/// A utility class to debounce function calls.
/// 
/// Usage:
/// ```dart
/// final _debouncer = Debouncer(milliseconds: 500);
/// 
/// _debouncer.run(() {
///   // Perform search or API call
/// });
/// ```
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
