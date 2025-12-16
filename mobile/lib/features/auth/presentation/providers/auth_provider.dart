import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/auth_repository.dart';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Auth state provider - watches auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges.map((state) => state.session?.user);
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Sign in state
class SignInState {
  final bool isLoading;
  final String? error;

  const SignInState({
    this.isLoading = false,
    this.error,
  });

  SignInState copyWith({bool? isLoading, String? error}) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Sign in notifier
class SignInNotifier extends StateNotifier<SignInState> {
  final AuthRepository _repo;

  SignInNotifier(this._repo) : super(const SignInState());

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repo.signInWithPassword(email: email, password: password);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An error occurred');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final signInProvider =
    StateNotifierProvider<SignInNotifier, SignInState>((ref) {
  return SignInNotifier(ref.watch(authRepositoryProvider));
});

/// Sign up state
class SignUpState {
  final bool isLoading;
  final String? error;
  final bool success;

  const SignUpState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  SignUpState copyWith({bool? isLoading, String? error, bool? success}) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

/// Sign up notifier
class SignUpNotifier extends StateNotifier<SignUpState> {
  final AuthRepository _repo;

  SignUpNotifier(this._repo) : super(const SignUpState());

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      await _repo.signUp(email: email, password: password);
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An error occurred');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final signUpProvider =
    StateNotifierProvider<SignUpNotifier, SignUpState>((ref) {
  return SignUpNotifier(ref.watch(authRepositoryProvider));
});

/// Forgot password state
class ForgotPasswordState {
  final bool isLoading;
  final String? error;
  final bool emailSent;

  const ForgotPasswordState({
    this.isLoading = false,
    this.error,
    this.emailSent = false,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? error,
    bool? emailSent,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      emailSent: emailSent ?? this.emailSent,
    );
  }
}

/// Forgot password notifier
class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final AuthRepository _repo;

  ForgotPasswordNotifier(this._repo) : super(const ForgotPasswordState());

  Future<bool> sendResetEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null, emailSent: false);

    try {
      await _repo.resetPasswordForEmail(email);
      state = state.copyWith(isLoading: false, emailSent: true);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An error occurred');
      return false;
    }
  }

  void reset() {
    state = const ForgotPasswordState();
  }
}

final forgotPasswordProvider =
    StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>((ref) {
  return ForgotPasswordNotifier(ref.watch(authRepositoryProvider));
});

/// Sign out provider
final signOutProvider = Provider<Future<void> Function()>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return () => repo.signOut();
});
