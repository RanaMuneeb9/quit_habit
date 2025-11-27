import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  /// Create user document in Firestore
  Future<void> createUserDocument(
    User user, {
    String? fullName,
  }) async {
    try {
      final userDoc = _usersCollection.doc(user.uid);
      final docSnapshot = await userDoc.get();

      // Only create if document doesn't exist
      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': fullName ?? user.displayName ?? '',
          'hasCompletedQuestionnaire': false,
          'coins': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to create user document: ${e.toString()}');
    }
  }

  /// Get user document from Firestore
  Future<Map<String, dynamic>?> getUserDocument(String uid) async {
    try {
      final docSnapshot = await _usersCollection.doc(uid).get();
      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user document: ${e.toString()}');
    }
  }

  /// Check if user has completed questionnaire
  Future<bool> hasCompletedQuestionnaire(String uid) async {
    try {
      final userDoc = await getUserDocument(uid);
      if (userDoc == null) {
        return false;
      }
      return userDoc['hasCompletedQuestionnaire'] as bool? ?? false;
    } catch (e) {
      // If there's an error, assume questionnaire is not completed
      return false;
    }
  }

  /// Mark questionnaire as completed
  Future<void> markQuestionnaireCompleted(String uid) async {
    try {
      await _usersCollection.doc(uid).update({
        'hasCompletedQuestionnaire': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(
          'Failed to mark questionnaire as completed: ${e.toString()}');
    }
  }

  /// Update user document
  Future<void> updateUserDocument(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _usersCollection.doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user document: ${e.toString()}');
    }
  }
}

