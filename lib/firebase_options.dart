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
    appId: '1:843842203982:android:6affb6cd5a41b9e6086e1f',
    messagingSenderId: '321868996666',
    projectId: 'reggypos-1829f',
    authDomain: 'pointify-9e51e.firebaseapp.com',
    storageBucket: 'pointify-9e51e.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDFzz1_9FxOLPU7Ax_2mF18cwMhLvgWxGM',
    appId: '1:843842203982:android:6affb6cd5a41b9e6086e1f',
    messagingSenderId: '321868996666',
    projectId: 'reggypos-1829f',
    storageBucket: 'pointify-9e51e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChT375xLHNl9t7psymx3Mw8fuv_E2Y5OE',
    appId: '1:843842203982:android:6affb6cd5a41b9e6086e1f',
    messagingSenderId: '321868996666',
    projectId: 'reggypos-1829f',
    storageBucket: 'pointify-9e51e.appspot.com',
    iosBundleId: 'com.pointify.pos',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyChT375xLHNl9t7psymx3Mw8fuv_E2Y5OE',
    appId: '1:843842203982:android:6affb6cd5a41b9e6086e1f',
    messagingSenderId: '321868996666',
    projectId: 'reggypos-1829f',
    storageBucket: 'pointify-9e51e.appspot.com',
    iosBundleId: 'com.pointify.com.RunnerTests',
  );
}
