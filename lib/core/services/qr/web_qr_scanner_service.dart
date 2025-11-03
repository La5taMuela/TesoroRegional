import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class WebQRScannerService {
  static bool get isWebSupported {
    if (!kIsWeb) return false;

    // Verificar si el navegador soporta getUserMedia
    return js.context.hasProperty('navigator') &&
        js.context['navigator'].hasProperty('mediaDevices') &&
        js.context['navigator']['mediaDevices'].hasProperty('getUserMedia');
  }

  static Future<bool> requestCameraPermission() async {
    if (!kIsWeb) return false;

    try {
      // Verificar si ya tenemos permisos
      final permissions = await html.window.navigator.permissions?.query({'name': 'camera'});
      if (permissions?.state == 'granted') {
        return true;
      }

      // Solicitar acceso a la cámara
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'facingMode': 'environment', // Cámara trasera preferida
          'width': {'ideal': 1280},
          'height': {'ideal': 720}
        }
      });

      if (stream != null) {
        // Detener el stream inmediatamente, solo queríamos verificar permisos
        stream.getTracks().forEach((track) => track.stop());
        return true;
      }
    } catch (e) {
      print('Error requesting camera permission: $e');
    }

    return false;
  }

  static Future<html.MediaStream?> getCameraStream() async {
    if (!kIsWeb) return null;

    try {
      return await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'facingMode': 'environment',
          'width': {'ideal': 1280, 'min': 640},
          'height': {'ideal': 720, 'min': 480}
        }
      });
    } catch (e) {
      print('Error getting camera stream: $e');
      return null;
    }
  }
}
