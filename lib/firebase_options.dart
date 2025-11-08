// firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: dotenv.get('FIREBASE_API_KEY_WEB'),
    appId: dotenv.get('FIREBASE_APP_ID_WEB'),
    messagingSenderId: dotenv.get('FIREBASE_MESSAGING_SENDER_ID_WEB'),
    projectId: dotenv.get('FIREBASE_PROJECT_ID'),
    authDomain: dotenv.get('FIREBASE_AUTH_DOMAIN'),
    storageBucket: dotenv.get('FIREBASE_STORAGE_BUCKET'),
    measurementId: dotenv.get('FIREBASE_MEASUREMENT_ID'),
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: dotenv.get('FIREBASE_API_KEY_ANDROID'),
    appId: dotenv.get('FIREBASE_APP_ID_ANDROID'),
    messagingSenderId: dotenv.get('FIREBASE_MESSAGING_SENDER_ID_WEB'),
    projectId: dotenv.get('FIREBASE_PROJECT_ID'),
    storageBucket: dotenv.get('FIREBASE_STORAGE_BUCKET'),
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: dotenv.get('FIREBASE_API_KEY_IOS'),
    appId: dotenv.get('FIREBASE_APP_ID_IOS'),
    messagingSenderId: dotenv.get('FIREBASE_MESSAGING_SENDER_ID_WEB'),
    projectId: dotenv.get('FIREBASE_PROJECT_ID'),
    storageBucket: dotenv.get('FIREBASE_STORAGE_BUCKET'),
    androidClientId: dotenv.get('FIREBASE_ANDROID_CLIENT_ID'),
    iosClientId: dotenv.get('FIREBASE_IOS_CLIENT_ID'),
    iosBundleId: dotenv.get('FIREBASE_IOS_BUNDLE_ID'),
  );
}