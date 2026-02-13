import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class FirebaseService {
  final _db = FirebaseFirestore.instance;

  /// Create user document in Firestore
  Future<void> createUserRecord({required String id, required String name, required String email, DateTime? expiry}) async {
    final data = {
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'expiryDate': expiry?.toUtc(),
      'isBlocked': false,
    };
    await _db.collection('users').doc(id).set(data);
  }

  /// Call a Cloud Function (HTTP) to create an Auth user and generate a password-reset link.
  /// The function URL should be provided in environment or configured in the app.
  Future<String> requestInviteLink({required String name, required String email, required int daysActive, required String functionUrl, required String secret}) async {
    final resp = await http.post(Uri.parse(functionUrl),
        headers: {'Content-Type': 'application/json', 'x-invite-secret': secret},
        body: jsonEncode({'name': name, 'email': email, 'daysActive': daysActive}));

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      return body['resetLink'] as String;
    }
    throw Exception('Invite function failed: ${resp.statusCode} ${resp.body}');
  }
}
