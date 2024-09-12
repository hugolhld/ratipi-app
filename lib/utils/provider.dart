import 'package:explore_fultter/utils/firebase.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_fultter/utils/web_socket_manager.dart';

class NotificationProvider with ChangeNotifier {
  final Map<String, List<Map<String, dynamic>>> _notificationsByRoute = {};
  bool _isLoading = false;
  bool _hasError = false;

  List<Map<String, dynamic>> getNotificationsForRoute(String routeId) {
    return _notificationsByRoute[routeId] ?? [];
  }

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
    _setLoadingState(true);

    try {
      final QuerySnapshot notifications = await FirestoreService().getNotificationsByStop(routeId);
      _notificationsByRoute[routeId] = notifications.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      print('Fetched ${notifications.docs.length} notifications for route $routeId');
    } catch (e) {
      _setErrorState(true);
      print('Error fetching notifications: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  // Fonction appelée lorsque de nouvelles notifications arrivent via WebSocket
  void _addNotification(Map<String, dynamic> newNotification) {
    print(newNotification);
    String routeId = newNotification['route']; // Assumes each notification has a 'routeId' field
    if (_notificationsByRoute.containsKey(routeId)) {
      _notificationsByRoute[routeId]!.add(newNotification);
    } else {
      _notificationsByRoute[routeId] = [newNotification];
    }
    notifyListeners(); // Informe les listeners que la liste des notifications a changé
  }

  // Met à jour l'état de chargement et notifie les listeners
  void _setLoadingState(bool isLoading) {
    if (_isLoading != isLoading) {
      _isLoading = isLoading;
      notifyListeners();
    }
  }

  // Met à jour l'état d'erreur et notifie les listeners
  void _setErrorState(bool hasError) {
    if (_hasError != hasError) {
      _hasError = hasError;
      notifyListeners();
    }
  }
}
