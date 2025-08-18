import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for ${defaultTargetPlatform.name}.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBfNV-OpmEK49EhQ-On9ZP21-99kiebTzU',
    appId: '1:459539217743:web:8007a0964f51c936e9993a',
    messagingSenderId: '459539217743',
    projectId: 'unilegal-14d0c',
    authDomain: 'unilegal-14d0c.firebaseapp.com',
    storageBucket: 'unilegal-14d0c.firebasestorage.app',
    measurementId: 'G-WXPXXH8LY7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAnqvs8CA_hDHB1yxo1zqxPRerPCypyxOQ',
    appId: '1:459539217743:android:64d013de603578e3e9993a',
    messagingSenderId: '459539217743',
    projectId: 'unilegal-14d0c',
    storageBucket: 'unilegal-14d0c.firebasestorage.app',
  );
} 