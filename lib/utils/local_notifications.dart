import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifications {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

      Future<void> initNotifications() async {

        var InitializationSettingsIOS = DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          onDidReceiveLocalNotification: (id, title, body, payload) async {
            print('Received local notification');
          },
        );

        var initializationSettings = InitializationSettings(
          android: const AndroidInitializationSettings('app_icon'),
          iOS: InitializationSettingsIOS,
        );

        await flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) async {
            print('Received notification response');
          });
      }

      notificationDetails() {
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel id',
            'channel name',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        );
      }

      Future<void> showNotification({required String body, required String title}) async {
        await flutterLocalNotificationsPlugin.show(
          0,
          title,
          body,
          notificationDetails(),
        );
      }


}