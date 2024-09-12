import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessage {
  final firebaseMessaging = FirebaseMessaging.instance;

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Handling a background message ${message.messageId}');
    print('title: ${message.notification?.title}');
    print('body: ${message.notification?.body}');
    print('payload: ${message.data}');
  }

  Future<void> initNotifications() async {
    await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    final fcmToken = await FirebaseMessaging.instance.getToken();
    print(fcmToken);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);


    // if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    //   print('User granted permission to receive notifications');
    // } else {
    //   print('User declined or has not accepted permission to receive notifications');
    // }
  }
}