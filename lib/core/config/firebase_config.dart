// core/config/firebase_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfig {
  static String get apiKeyWeb => _get('FIREBASE_API_KEY_WEB');
  static String get appIdWeb => _get('FIREBASE_APP_ID_WEB');
  static String get messagingSenderIdWeb => _get('FIREBASE_MESSAGING_SENDER_ID_WEB');
  static String get projectId => _get('FIREBASE_PROJECT_ID');
  static String get authDomain => _get('FIREBASE_AUTH_DOMAIN');
  static String get storageBucket => _get('FIREBASE_STORAGE_BUCKET');
  static String get measurementId => _get('FIREBASE_MEASUREMENT_ID');

  static String get apiKeyAndroid => _get('FIREBASE_API_KEY_ANDROID');
  static String get appIdAndroid => _get('FIREBASE_APP_ID_ANDROID');

  static String get apiKeyIos => _get('FIREBASE_API_KEY_IOS');
  static String get appIdIos => _get('FIREBASE_APP_ID_IOS');
  static String get iosClientId => _get('FIREBASE_IOS_CLIENT_ID');
  static String get androidClientId => _get('FIREBASE_ANDROID_CLIENT_ID');
  static String get iosBundleId => _get('FIREBASE_IOS_BUNDLE_ID');

  static String _get(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception('Environment variable $key is not set');
    }
    return value;
  }
}