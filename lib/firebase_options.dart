import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDItqnV6baN3ZhFTZzTdGuSJyV-BUiYams',
    appId: '1:321868996666:web:d2bbd5e4b7c32c32f59503',
    messagingSenderId: '321868996666',
    projectId: 'pointify-9e51e',
    authDomain: 'pointify-9e51e.firebaseapp.com',
    storageBucket: 'pointify-9e51e.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDFzz1_9FxOLPU7Ax_2mF18cwMhLvgWxGM',
    appId: '1:321868996666:android:ade35dae952eae78f59503',
    messagingSenderId: '321868996666',
    projectId: 'pointify-9e51e',
    storageBucket: 'pointify-9e51e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChT375xLHNl9t7psymx3Mw8fuv_E2Y5OE',
    appId: '1:321868996666:ios:46a2a5c8f23369dbf59503',
    messagingSenderId: '321868996666',
    projectId: 'pointify-9e51e',
    storageBucket: 'pointify-9e51e.appspot.com',
    iosBundleId: 'com.pointify.pos',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyChT375xLHNl9t7psymx3Mw8fuv_E2Y5OE',
    appId: '1:321868996666:ios:e8b3921e58b03b21f59503',
    messagingSenderId: '321868996666',
    projectId: 'pointify-9e51e',
    storageBucket: 'pointify-9e51e.appspot.com',
    iosBundleId: 'com.pointify.com.RunnerTests',
  );
}
