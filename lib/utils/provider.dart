import 'dart:async';
import 'package:ratipi/utils/firebase.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ratipi/utils/web_socket_manager.dart';

class NotificationProvider with ChangeNotifier {
  final Map<String, List<Map<String, dynamic>>> _notificationsByRoute = {};
  List<Map<String, dynamic>> _notifications = [];

  bool _isLoading = false;
  bool _hasError = false;
  late Timer _cleanupTimer;

  List<Map<String, dynamic>> getNotificationsForRoute(String routeId) {
    final notifications = _notificationsByRoute[routeId];
    if (notifications != null) {
      notifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      return notifications;
    }
    return [];
  }

  List<Map<String, dynamic>> get allNotifications => _notifications;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  NotificationProvider() {
    // Initialiser l'écouteur WebSocket dès la création du provider
    WebSocketManager().messageStream.listen((message) {
      _addNotification(message);
    });

    _cleanupTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _cleanupNotifications();
    });
  }

  // Fonction pour récupérer les notifications depuis Firestore
  Future<void> fetchNotifications(String routeId) async {
    _setLoadingState(true);

    try {
      final QuerySnapshot notifications =
          await FirestoreService().getNotificationsByStop(routeId);
      _notificationsByRoute[routeId] = notifications.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      _setErrorState(true);
      print('Error fetching notifications: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> fetchAllNotification() async {
    _setLoadingState(true);

    try {
      final QuerySnapshot notifications =
          await FirestoreService().getAllNotifications();
      _notifications = notifications.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      _setErrorState(true);
      print('Error fetching notifications: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  // Fonction appelée lorsque de nouvelles notifications arrivent via WebSocket
  void _addNotification(Map<String, dynamic> newNotification) {
    String routeId = newNotification[
        'route']; // Assumes each notification has a 'routeId' field
    if (_notificationsByRoute.containsKey(routeId)) {
      _notificationsByRoute[routeId]!.add(newNotification);
    } else {
      _notificationsByRoute[routeId] = [newNotification];
    }
    notifyListeners(); // Informe les listeners que la liste des notifications a changé
  }

  void _cleanupNotifications() {
    final now = DateTime.now();
    final fifteenMinutesAgo = now.subtract(const Duration(minutes: 15));

    _notificationsByRoute.forEach((routeId, notifications) {
      _notificationsByRoute[routeId] = notifications.where((notification) {
        final timestamp = notification['timestamp'];
        DateTime? notificationTime;

        if (timestamp is Timestamp) {
          notificationTime = timestamp.toDate();
        } else if (timestamp is int) {
          notificationTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        } else if (timestamp is DateTime) {
          notificationTime = timestamp;
        } else {
          return false;
        }
        return notificationTime.isAfter(fifteenMinutesAgo);
      }).toList();
    });

    notifyListeners();
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
