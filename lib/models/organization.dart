import 'package:equatable/equatable.dart';

/// Organization model representing a school/institution
class Organization extends Equatable {
  final String id;
  final String name;
  final String code;
  final String? logo;
  final String primaryColor; // Hex color code
  final String? contactEmail;
  final String? contactPhone;
  final String? address;

  const Organization({
    required this.id,
    required this.name,
    required this.code,
    this.logo,
    this.primaryColor = '#2196F3',
    this.contactEmail,
    this.contactPhone,
    this.address,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        logo,
        primaryColor,
        contactEmail,
        contactPhone,
        address,
      ];

  Organization copyWith({
    String? id,
    String? name,
    String? code,
    String? logo,
    String? primaryColor,
    String? contactEmail,
    String? contactPhone,
    String? address,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      logo: logo ?? this.logo,
      primaryColor: primaryColor ?? this.primaryColor,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
    );
  }
}

