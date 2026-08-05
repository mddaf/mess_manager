import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final profile = await _authRepository.getCurrentUserProfile();
      if (profile != null) {
        emit(Authenticated(profile));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      final profile = await _authRepository.getCurrentUserProfile();
      if (profile != null) {
        emit(Authenticated(profile));
      } else {
        emit(const AuthError('Failed to fetch user profile'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll(RegExp(r'\[.*?\]\s*'), '')));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      final profile = await _authRepository.getCurrentUserProfile();
      if (profile != null) {
        emit(Authenticated(profile));
      } else {
        emit(const AuthError('Failed to create user profile'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll(RegExp(r'\[.*?\]\s*'), '')));
    }
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final cred = await _authRepository.signInWithGoogle();
      if (cred != null) {
        final profile = await _authRepository.getCurrentUserProfile();
        if (profile != null) {
          emit(Authenticated(profile));
        } else {
          emit(const AuthError('Failed to retrieve Google user profile'));
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll(RegExp(r'\[.*?\]\s*'), '')));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _authRepository.signOut();
    emit(Unauthenticated());
  }
}
