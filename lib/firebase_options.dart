// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyDQX4OvYR89rpG-DrxnURfcrj2PDo4gptQ',
    appId: '1:140812173711:android:96e1d4585ea3d59f678bfa',
    messagingSenderId: '140812173711',
    projectId: 'fir-flutter-919ef',
    storageBucket: 'fir-flutter-919ef.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBtLucn54T1Ubu03CRAkFm86y-A-k7qohs',
    appId: '1:140812173711:web:efb8d140c03a4b49678bfa',
    messagingSenderId: '140812173711',
    projectId: 'fir-flutter-919ef',
    authDomain: 'fir-flutter-919ef.firebaseapp.com',
    storageBucket: 'fir-flutter-919ef.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC2m7tkkCbK3cxKin2W2RV9ZXp6BJ3Bh40',
    appId: '1:140812173711:ios:66f8f1bb3667680f678bfa',
    messagingSenderId: '140812173711',
    projectId: 'fir-flutter-919ef',
    storageBucket: 'fir-flutter-919ef.firebasestorage.app',
    iosClientId: '140812173711-6g97funpmpujiaa79jkdbn2u4sg5s4q0.apps.googleusercontent.com',
    iosBundleId: 'com.example.login',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC2m7tkkCbK3cxKin2W2RV9ZXp6BJ3Bh40',
    appId: '1:140812173711:ios:66f8f1bb3667680f678bfa',
    messagingSenderId: '140812173711',
    projectId: 'fir-flutter-919ef',
    storageBucket: 'fir-flutter-919ef.firebasestorage.app',
    iosClientId: '140812173711-6g97funpmpujiaa79jkdbn2u4sg5s4q0.apps.googleusercontent.com',
    iosBundleId: 'com.example.login',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBtLucn54T1Ubu03CRAkFm86y-A-k7qohs',
    appId: '1:140812173711:web:28b9ca15884bdc0a678bfa',
    messagingSenderId: '140812173711',
    projectId: 'fir-flutter-919ef',
    authDomain: 'fir-flutter-919ef.firebaseapp.com',
    storageBucket: 'fir-flutter-919ef.firebasestorage.app',
  );

}