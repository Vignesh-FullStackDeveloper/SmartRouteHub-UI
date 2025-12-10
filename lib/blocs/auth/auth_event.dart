import 'package:equatable/equatable.dart';
import '../../models/user.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Admin login event
class AdminLoginRequested extends AuthEvent {
  final String organizationCode;
  final String emailOrPhone;
  final String password;

  const AdminLoginRequested({
    required this.organizationCode,
    required this.emailOrPhone,
    required this.password,
  });

  @override
  List<Object?> get props => [organizationCode, emailOrPhone, password];
}

/// Create organization and admin event
class CreateOrganizationAndAdminRequested extends AuthEvent {
  final String organizationName;
  final String organizationCode;
  final String adminName;
  final String adminEmail;
  final String? adminPhone;
  final String adminPassword;
  final String primaryColor;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;

  const CreateOrganizationAndAdminRequested({
    required this.organizationName,
    required this.organizationCode,
    required this.adminName,
    required this.adminEmail,
    this.adminPhone,
    required this.adminPassword,
    this.primaryColor = '#2196F3',
    this.contactEmail,
    this.contactPhone,
    this.address,
  });

  @override
  List<Object?> get props => [
        organizationName,
        organizationCode,
        adminName,
        adminEmail,
        adminPhone,
        adminPassword,
        primaryColor,
        contactEmail,
        contactPhone,
        address,
      ];
}

/// Driver login event
class DriverLoginRequested extends AuthEvent {
  final String organizationCode;
  final String phone;
  final String? driverId;
  final String otp;

  const DriverLoginRequested({
    required this.organizationCode,
    required this.phone,
    this.driverId,
    required this.otp,
  });

  @override
  List<Object?> get props => [organizationCode, phone, driverId, otp];
}

/// Parent login event
class ParentLoginRequested extends AuthEvent {
  final String organizationCode;
  final String? phone;
  final String? email;
  final String? otp;
  final String? password;

  const ParentLoginRequested({
    required this.organizationCode,
    this.phone,
    this.email,
    this.otp,
    this.password,
  });

  @override
  List<Object?> get props => [organizationCode, phone, email, otp, password];
}

/// Send OTP event
class SendOtpRequested extends AuthEvent {
  final String phone;

  const SendOtpRequested(this.phone);

  @override
  List<Object?> get props => [phone];
}

/// Logout event
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Check auth status event
class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

/// User updated event
class UserUpdated extends AuthEvent {
  final User user;

  const UserUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

