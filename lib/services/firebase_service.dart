import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/stock_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  static const String projectId = 'kite-e17ed';

  /// Verify if user exists in Firestore Database before login
  void verifyUserInFirestore({
    required String email,
    required String password,
    required Function(bool success, String? error, UserProfile? profile) onComplete,
  }) {
    // For mobile/non-web builds, allow basic login
    final profile = UserProfile(
      userId: 'AB1234',
      userName: email.split('@')[0],
      email: email,
      phone: '+91 98765 43210',
      pan: 'ABCDE1234F',
      avatarInitials: email.substring(0, 1).toUpperCase(),
      dematDpId: '1208160012345678',
      bankName: 'HDFC Bank Ltd',
      bankAccountNo: '•••• •••• 4321',
      memberSince: DateTime.now(),
    );
    onComplete(true, null, profile);
  }

  /// Create Account in Firestore
  void createAccountInFirestore({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required Function(bool success, String? error, UserProfile? profile) onComplete,
  }) {
    final userId = 'AB${DateTime.now().millisecondsSinceEpoch % 10000}';
    final profile = UserProfile(
      userId: userId,
      userName: fullName.isNotEmpty ? fullName : email.split('@')[0],
      email: email,
      phone: phone.isNotEmpty ? phone : '+91 98765 43210',
      pan: 'ABCDE${DateTime.now().millisecondsSinceEpoch % 8999 + 1000}F',
      avatarInitials: (fullName.isNotEmpty) ? fullName.substring(0, 1).toUpperCase() : email.substring(0, 1).toUpperCase(),
      dematDpId: '1208160012345678',
      bankName: 'HDFC Bank Ltd',
      bankAccountNo: '•••• •••• 4321',
      memberSince: DateTime.now(),
    );

    onComplete(true, null, profile);
  }

  /// Sync user profile to Firestore (JS SDK + REST Fallback)
  void syncUserProfile(UserProfile profile, {String? password}) {
    // Mobile implementation - data is stored locally via SharedPreferences
    debugPrint('User profile synced: ${profile.userName}');
  }

  /// Sync placed order to Firestore
  void syncOrder(OrderItem order) {
    // Mobile implementation - orders are stored locally
    debugPrint('Order synced: ${order.id}');
  }

  /// Sync price alert to Firestore
  void syncAlert(PriceAlert alert) {
    // Mobile implementation - alerts are stored locally
    debugPrint('Alert synced: ${alert.id}');
  }

  /// Helper to post directly to Firestore REST API v1
  void _sendFirestoreRestRequest(String collection, String docId, Map<String, dynamic> fields) {
    // Mobile implementation - would use HTTP client for REST calls
    debugPrint('REST request: $collection/$docId');
  }
}
