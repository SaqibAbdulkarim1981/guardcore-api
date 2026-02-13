import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class MockService extends ChangeNotifier {
  final List<AppUser> _users = [];
  final _uuid = const Uuid();

  List<AppUser> get users => List.unmodifiable(_users);

  MockService() {
    // seed with some demo users
    _users.addAll([
      AppUser(id: _uuid.v4(), name: 'Alice Smith', email: 'alice@example.com', expiryDate: DateTime.now().add(const Duration(days: 30))),
      AppUser(id: _uuid.v4(), name: 'Bob Johnson', email: 'bob@example.com', expiryDate: DateTime.now().add(const Duration(days: 5))),
    ]);
    // start periodic expiry check
    Timer.periodic(const Duration(hours: 1), (_) => _applyExpiry());
  }

  void _applyExpiry() {
    var changed = false;
    for (var i = 0; i < _users.length; i++) {
      final u = _users[i];
      if (!u.isBlocked && u.isExpired) {
        _users[i] = u.copyWith(isBlocked: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  Future<void> addUser({required String name, required String email, required int daysActive}) async {
    final user = AppUser(
      id: _uuid.v4(),
      name: name,
      email: email,
      expiryDate: DateTime.now().add(Duration(days: daysActive)),
    );
    _users.insert(0, user);
    notifyListeners();
    // placeholder: send invitation email (implement real email sending later)
  }

  Future<void> blockUser(String id) async {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      _users[idx] = _users[idx].copyWith(isBlocked: true);
      notifyListeners();
    }
  }

  Future<void> unblockUser(String id, {int? extendDays}) async {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      final newExpiry = extendDays != null ? DateTime.now().add(Duration(days: extendDays)) : _users[idx].expiryDate;
      _users[idx] = _users[idx].copyWith(isBlocked: false, expiryDate: newExpiry);
      notifyListeners();
    }
  }
}
