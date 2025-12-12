import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

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
  AdsService._internal() {
    loadRewardedAd();
  }

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

  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;
  final String _adUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID

  /// Load a rewarded ad
  Future<void> loadRewardedAd() async {
    if (_isAdLoading || _rewardedAd != null) return;
    _isAdLoading = true;

    await RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _rewardedAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isAdLoading = false;
        },
      ),
    );
  }

  bool get isAdReady => _rewardedAd != null;

  /// Show rewarded ad and award coins if successful
  /// Returns the new coin balance if successful, null otherwise
  Future<int?> showRewardedAd(String uid) async {
    debugPrint('showRewardedAd called for user $uid');
    if (_rewardedAd == null) {
      debugPrint('Ad is null, triggering load');
      loadRewardedAd(); // Trigger load if not already loading
      throw AdsServiceException(
        'Ad is not ready yet. Please try again in a moment.',
        code: 'ad-not-ready',
      );
    }

    final Completer<int?> completer = Completer<int?>();

    // Set full screen content callbacks ensuring we handle dismissal and reward
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Ad dismissed full screen content');
        ad.dispose();
        if (!completer.isCompleted) {
          // Give reward callback time to fire before completing with null
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!completer.isCompleted) {
              debugPrint('Timeout: completing with null (no reward earned)');
              completer.complete(null);
            }
          });
        }
        _rewardedAd = null; // Clear current ad
        loadRewardedAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Ad failed to show: $error');
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete(null);
        }
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Ad showed full screen content');
      },
      onAdImpression: (ad) {
        debugPrint('Ad recorded impression');
      },
    );

    try {
      debugPrint('Attempting to show ad');
      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) async {
          debugPrint('User earned reward callback: ${rewardItem.amount} ${rewardItem.type}');
          try {
            // Process reward immediately when earned
            final newCoins = await watchAd(uid);
            debugPrint('Coins awarded: $newCoins');
            if (!completer.isCompleted) {
              completer.complete(newCoins);
            }
          } catch (e) {
            debugPrint("Error awarding coins: $e");
            if (!completer.isCompleted) {
               completer.complete(null);
            }
          }
        },
      );
    } catch (e) {
      debugPrint('Exception calling _rewardedAd!.show: $e');
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      _rewardedAd = null;
      loadRewardedAd();
    }
    
    return completer.future;
  }
  /// Process ad watch and award coins (Internal or direct use)
  /// Returns the new coin balance
  Future<int> watchAd(String uid) async {
    try {
      // Update in Firestore using atomic increment
      await _usersCollection.doc(uid).update({
        'coins': FieldValue.increment(coinsPerAd),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Fetch updated balance
      return await getCoins(uid);
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

      // Add coins atomically
      await _usersCollection.doc(uid).update({
        'coins': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return await getCoins(uid);
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


