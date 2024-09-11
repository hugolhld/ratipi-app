class NotificationModel {
  final String stop;
  final String uuid;
  final String alert;
  final String route;

  NotificationModel({
    required this.stop,
    required this.uuid,
    required this.alert,
    required this.route,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      stop: map['stop'] ?? '',
      uuid: map['uuid'] ?? '',
      alert: map['alert'] ?? '',
      route: map['route'] ?? '',
    );
  }
}
