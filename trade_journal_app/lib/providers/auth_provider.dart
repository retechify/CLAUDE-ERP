import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService) {
    _subscription = _authService.authStateChanges.listen((localUser) {
      user = localUser;
      notifyListeners();
    });
  }

  final AuthService _authService;
  late final StreamSubscription<LocalUser?> _subscription;

  LocalUser? user;
  bool isLoading = false;
  String? error;

  bool get isAuthenticated => user != null;
  String? get userId => user?.id;

  Future<bool> signIn(String email, String password) async {
    return _runAuthAction(
      () => _authService.signIn(email: email, password: password),
    );
  }

  Future<bool> signUp(String email, String password) async {
    return _runAuthAction(
      () => _authService.signUp(email: email, password: password),
    );
  }

  Future<void> signOut() => _authService.signOut();

  Future<bool> _runAuthAction(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
