// ignore_for_file: empty_catches

import 'package:flutter/services.dart';

class LockTaskController {
  static const platform = MethodChannel('proj.seb.sibiti/locktask');

  // Mengaktifkan Lock Task Mode
  static Future<void> startLockTask() async {
    try {
      await platform.invokeMethod('startLockTask');
    } on PlatformException {}
  }

  // Menonaktifkan Lock Task Mode
  static Future<void> stopLockTask() async {
    try {
      await platform.invokeMethod('stopLockTask');
    } on PlatformException {}
  }
}
