import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// User Account Model
class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toMap(String passwordHash) {
    return {
      'fullName': fullName,
      'email': email.toLowerCase().trim(),
      'passwordHash': passwordHash,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    DateTime created;
    if (d['createdAt'] is Timestamp) {
      created = (d['createdAt'] as Timestamp).toDate();
    } else {
      created = DateTime.now();
    }

    return AppUser(
      uid: doc.id,
      fullName: d['fullName'] ?? 'User',
      email: d['email'] ?? '',
      createdAt: created,
    );
  }
}

/// Authentication Service managing Firestore Credentials
class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  bool _isFirebaseActive = false;

  // Mock users database table for offline lab demonstration
  final Map<String, Map<String, dynamic>> _mockUsersDb = {};

  void init() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isFirebaseActive = true;
      }
    } catch (_) {
      _isFirebaseActive = false;
    }

    // Pre-seed a test demo account
    final demoHash = hashPassword('Password123');
    _mockUsersDb['student@college.edu'] = {
      'uid': 'usr_demo_01',
      'fullName': 'Lab Student',
      'email': 'student@college.edu',
      'passwordHash': demoHash,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    };
  }

  /// Hashes passwords securely using SHA-256 before Firestore storage
  static String hashPassword(String password) {
    final bytes = utf8.encode('salt_flutter_lab_$password');
    return sha256.convert(bytes).toString();
  }

  /// SIGN UP / REGISTRATION
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.toLowerCase().trim();
    final passwordHash = hashPassword(password);

    if (_isFirebaseActive) {
      final col = FirebaseFirestore.instance.collection('users');
      final existing = await col.where('email', isEqualTo: normalizedEmail).limit(1).get();

      if (existing.docs.isNotEmpty) {
        throw Exception('An account with this email already exists in Firestore.');
      }

      final docRef = await col.add({
        'fullName': fullName.trim(),
        'email': normalizedEmail,
        'passwordHash': passwordHash,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AppUser(
        uid: docRef.id,
        fullName: fullName.trim(),
        email: normalizedEmail,
        createdAt: DateTime.now(),
      );
    } else {
      // Offline fallback handling
      if (_mockUsersDb.containsKey(normalizedEmail)) {
        throw Exception('An account with this email already exists in Firestore.');
      }

      final uid = 'usr_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();
      _mockUsersDb[normalizedEmail] = {
        'uid': uid,
        'fullName': fullName.trim(),
        'email': normalizedEmail,
        'passwordHash': passwordHash,
        'createdAt': now,
      };

      return AppUser(
        uid: uid,
        fullName: fullName.trim(),
        email: normalizedEmail,
        createdAt: now,
      );
    }
  }

  /// SIGN IN / LOGIN
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.toLowerCase().trim();
    final passwordHash = hashPassword(password);

    if (_isFirebaseActive) {
      final col = FirebaseFirestore.instance.collection('users');
      final query = await col
          .where('email', isEqualTo: normalizedEmail)
          .where('passwordHash', isEqualTo: passwordHash)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Invalid email or password. Please try again.');
      }

      return AppUser.fromDoc(query.docs.first);
    } else {
      // Offline fallback verification
      final userRecord = _mockUsersDb[normalizedEmail];
      if (userRecord == null || userRecord['passwordHash'] != passwordHash) {
        throw Exception('Invalid email or password. Please check credentials.');
      }

      return AppUser(
        uid: userRecord['uid'],
        fullName: userRecord['fullName'],
        email: userRecord['email'],
        createdAt: userRecord['createdAt'] is DateTime ? userRecord['createdAt'] : DateTime.now(),
      );
    }
  }
}
