import 'package:cloud_firestore/cloud_firestore.dart';

/// Custom exception for ads service errors
class AdsServiceException implements Exception {
  final String message;
  final String? code;

  AdsServiceException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Service for managing ads and coins
class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  /// Coins awarded per ad watch
  static const int coinsPerAd = 10;

  /// Get real-time stream of coin balance for a user
  Stream<int> getCoinsStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return 0;
      }
      final data = snapshot.data() as Map<String, dynamic>?;
      return data?['coins'] as int? ?? 0;
    });
  }

  /// Get current coin balance (one-time fetch)
  Future<int> getCoins(String uid) async {
    try {
      final docSnapshot = await _usersCollection.doc(uid).get();
      if (!docSnapshot.exists) {
        return 0;
      }
      final data = docSnapshot.data() as Map<String, dynamic>?;
      return data?['coins'] as int? ?? 0;
    } catch (e) {
      throw AdsServiceException(
        'Failed to get coins: ${e.toString()}',
        code: 'get-coins-failed',
      );
    }
  }

  /// Process ad watch and award coins
  /// Returns the new coin balance
  Future<int> watchAd(String uid) async {
    try {
      // Get current coins
      final currentCoins = await getCoins(uid);

      // Award coins
      final newCoins = currentCoins + coinsPerAd;

      // Update in Firestore
      await _usersCollection.doc(uid).update({
        'coins': newCoins,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return newCoins;
    } on AdsServiceException {
      rethrow;
    } catch (e) {
      throw AdsServiceException(
        'Failed to process ad watch: ${e.toString()}',
        code: 'watch-ad-failed',
      );
    }
  }

  /// Deduct coins (e.g., for relapse penalty)
  /// Throws exception if insufficient coins
  Future<int> deductCoins(String uid, int amount) async {
    try {
      if (amount < 0) {
        throw AdsServiceException(
          'Deduction amount cannot be negative',
          code: 'invalid-amount',
        );
      }

      // Get current coins
      final currentCoins = await getCoins(uid);

      // Check if sufficient coins
      if (currentCoins < amount) {
        throw AdsServiceException(
          'Insufficient coins',
          code: 'insufficient-coins',
        );
      }

      // Deduct coins
      final newCoins = currentCoins - amount;

      // Update in Firestore
      await _usersCollection.doc(uid).update({
        'coins': newCoins,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return newCoins;
    } on AdsServiceException {
      rethrow;
    } catch (e) {
      throw AdsServiceException(
        'Failed to deduct coins: ${e.toString()}',
        code: 'deduct-coins-failed',
      );
    }
  }

  /// Add coins (for other purposes if needed)
  Future<int> addCoins(String uid, int amount) async {
    try {
      if (amount < 0) {
        throw AdsServiceException(
          'Amount cannot be negative',
          code: 'invalid-amount',
        );
      }

      // Get current coins
      final currentCoins = await getCoins(uid);

      // Add coins
      final newCoins = currentCoins + amount;

      // Update in Firestore
      await _usersCollection.doc(uid).update({
        'coins': newCoins,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return newCoins;
    } on AdsServiceException {
      rethrow;
    } catch (e) {
      throw AdsServiceException(
        'Failed to add coins: ${e.toString()}',
        code: 'add-coins-failed',
      );
    }
  }
}


