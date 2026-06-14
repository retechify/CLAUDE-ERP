import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocalUser {
  const LocalUser({required this.id, required this.email});

  final String id;
  final String email;
}

class AuthService {
  final _authStateController = StreamController<LocalUser?>.broadcast();
  final _uuid = const Uuid();

  LocalUser? _currentUser;

  Stream<LocalUser?> get authStateChanges async* {
    await _restoreSession();
    yield _currentUser;
    yield* _authStateController.stream;
  }

  LocalUser? get currentUser => _currentUser;

  Future<void> signIn({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _readUsers();
    final user = users[normalizedEmail];
    if (user == null || user['password'] != password) {
      throw AuthException('Invalid email or password.');
    }
    await _setCurrentUser(
      LocalUser(id: user['id'] as String, email: normalizedEmail),
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _readUsers();
    if (users.containsKey(normalizedEmail)) {
      throw AuthException('An account already exists for this email.');
    }
    final user = {'id': _uuid.v4(), 'password': password};
    users[normalizedEmail] = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
    await _setCurrentUser(
      LocalUser(id: user['id'] as String, email: normalizedEmail),
    );
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdKey);
    await prefs.remove(_currentUserEmailKey);
    _currentUser = null;
    _authStateController.add(null);
  }

  Future<void> _restoreSession() async {
    if (_currentUser != null) return;
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_currentUserIdKey);
    final email = prefs.getString(_currentUserEmailKey);
    if (id != null && email != null) {
      _currentUser = LocalUser(id: id, email: email);
    }
  }

  Future<void> _setCurrentUser(LocalUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserIdKey, user.id);
    await prefs.setString(_currentUserEmailKey, user.email);
    _currentUser = user;
    _authStateController.add(user);
  }

  Future<Map<String, dynamic>> _readUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return {};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;
}

const _usersKey = 'local_users';
const _currentUserIdKey = 'current_user_id';
const _currentUserEmailKey = 'current_user_email';
