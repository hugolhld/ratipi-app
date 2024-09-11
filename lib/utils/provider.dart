import 'package:explore_fultter/utils/firebase.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_fultter/utils/web_socket_manager.dart';

class NotificationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  bool _hasError = false;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  NotificationProvider() {
    // Initialiser l'écouteur WebSocket dès la création du provider
    WebSocketManager().messageStream.listen((message) {
      _addNotification(message);
    });
  }

  // Fonction pour récupérer les notifications depuis Firestore
  Future<void> fetchNotifications(String routeId) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final QuerySnapshot notifications = await FirestoreService().getNotificationsByStop(routeId);
      _notifications = notifications.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      print('Error fetching notifications: $e');
    }

    notifyListeners();
  }

  // Fonction appelée lorsque de nouvelles notifications arrivent via WebSocket
  void _addNotification(Map<String, dynamic> newNotification) {
    _notifications.add(newNotification);
    notifyListeners(); // Informe les listeners que la liste des notifications a changé
  }
}