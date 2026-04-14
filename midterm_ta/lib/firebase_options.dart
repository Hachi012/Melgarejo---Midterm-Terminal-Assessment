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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAYvCCbAObvx6_KU1rINnOEE6p8iGPo7MQ',
    appId: '1:1049037203473:android:4966026a10b281c3dc69b0',
    messagingSenderId: '1049037203473',
    projectId: 'strm-163ec',
    storageBucket: 'strm-163ec.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYvCCbAObvx6_KU1rINnOEE6p8iGPo7MQ',
    appId: '1:1049037203473:ios:placeholder',
    messagingSenderId: '1049037203473',
    projectId: 'strm-163ec',
    storageBucket: 'strm-163ec.firebasestorage.app',
    iosBundleId: 'midterm.ta',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAYvCCbAObvx6_KU1rINnOEE6p8iGPo7MQ',
    appId: '1:1049037203473:macos:placeholder',
    messagingSenderId: '1049037203473',
    projectId: 'strm-163ec',
    storageBucket: 'strm-163ec.firebasestorage.app',
    iosBundleId: 'midterm.ta',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAYvCCbAObvx6_KU1rINnOEE6p8iGPo7MQ',
    appId: '1:1049037203473:web:placeholder',
    messagingSenderId: '1049037203473',
    projectId: 'strm-163ec',
    storageBucket: 'strm-163ec.firebasestorage.app',
  );
}
