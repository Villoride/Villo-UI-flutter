import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiBase {
  // Change USER_PC_IP to your PC IP if testing on a real device
  static const _pcIp = '192.168.1.100'; // <-- replace when using real device

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    // iOS simulator uses localhost; change if using real iPhone
    return 'http://localhost:8080';
  }

  // helper if you want to use phone + PC LAN IP instead of emulator:
  static String baseUrlForRealDevice() => 'http://$_pcIp:8080';
}
