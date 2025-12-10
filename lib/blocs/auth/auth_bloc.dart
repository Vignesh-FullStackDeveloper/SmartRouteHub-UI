import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiAuthService _authService;

  AuthBloc({ApiAuthService? authService})
      : _authService = authService ?? ApiAuthService(),
        super(const AuthInitial()) {
    on<AdminLoginRequested>(_onAdminLoginRequested);
    on<CreateOrganizationAndAdminRequested>(_onCreateOrganizationAndAdminRequested);
    on<DriverLoginRequested>(_onDriverLoginRequested);
    on<ParentLoginRequested>(_onParentLoginRequested);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<UserUpdated>(_onUserUpdated);
  }

  void _onUserUpdated(UserUpdated event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.user));
  }

  Future<void> _onAdminLoginRequested(
    AdminLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.login(
        email: event.emailOrPhone.contains('@')
            ? event.emailOrPhone
            : '$event.emailOrPhone@example.com',
        password: event.password,
        organizationCode: event.organizationCode,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCreateOrganizationAndAdminRequested(
    CreateOrganizationAndAdminRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.createOrganizationAndAdmin(
        organizationName: event.organizationName,
        organizationCode: event.organizationCode,
        adminName: event.adminName,
        adminEmail: event.adminEmail,
        adminPhone: event.adminPhone,
        adminPassword: event.adminPassword,
        primaryColor: event.primaryColor,
        contactEmail: event.contactEmail,
        contactPhone: event.contactPhone,
        address: event.address,
      );
      
      // Load organization immediately after creation
      if (user.organizationId.isNotEmpty) {
        // Organization will be loaded in AppNavigator
      }
      
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onDriverLoginRequested(
    DriverLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.loginDriver(
        organizationCode: event.organizationCode,
        phone: event.phone,
        driverId: event.driverId,
        otp: event.otp,
      );
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Driver login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onParentLoginRequested(
    ParentLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.loginParent(
        organizationCode: event.organizationCode,
        phone: event.phone,
        email: event.email,
        otp: event.otp,
        password: event.password,
      );
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Parent login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.sendOtp(event.phone);
      emit(OtpSent(event.phone));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _authService.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Try to verify token
      final user = await _authService.verifyToken();
      emit(AuthAuthenticated(user));
    } catch (e) {
      // Token invalid or expired
      emit(const AuthUnauthenticated());
    }
  }
}

