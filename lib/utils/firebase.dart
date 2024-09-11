import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new document to a collection
  Future<void> addDocument(String collectionPath, Map<String, dynamic> data) async {
    try {
      await _db.collection(collectionPath).add(data);
      print('Document added successfully.');
    } catch (e) {
      print('Error adding document: $e');
    }
  }

  // Get a document by its ID from a collection
  Future<DocumentSnapshot> getDocumentById(String collectionPath, String docId) async {
    try {
      DocumentSnapshot document = await _db.collection(collectionPath).doc(docId).get();
      return document;
    } catch (e) {
      print('Error getting document: $e');
      rethrow;
    }
  }

  // Get documents by stop from notifications collection and timestamp est inférieur à il y'a 15 minutes
  Future<QuerySnapshot> getNotificationsByStop(String route) async {
    try {
      QuerySnapshot notifications = await _db
          .collection('notifications')
          .where('route', isEqualTo: route)
          .where('timestamp', isGreaterThan: DateTime.now().subtract(const Duration(minutes: 15)).millisecondsSinceEpoch)
          .get();
      return notifications;
    } catch (e) {
      print('Error getting notifications: $e');
      rethrow;
    }
  }

  // Get all documents from a collection
  Future<QuerySnapshot> getDocuments(String collectionPath) async {
    return await _db.collection(collectionPath).get();
  }

  // Update a document in a collection
  Future<void> updateDocument(String collectionPath, String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection(collectionPath).doc(docId).update(data);
      print('Document updated successfully.');
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  // Delete a document from a collection
  Future<void> deleteDocument(String collectionPath, String docId) async {
    try {
      await _db.collection(collectionPath).doc(docId).delete();
      print('Document deleted successfully.');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
}
