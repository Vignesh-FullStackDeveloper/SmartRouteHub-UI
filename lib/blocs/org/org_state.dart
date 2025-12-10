import 'package:equatable/equatable.dart';
import '../../models/organization.dart';

/// Organization states
abstract class OrgState extends Equatable {
  const OrgState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OrgInitial extends OrgState {
  const OrgInitial();
}

/// Loading state
class OrgLoading extends OrgState {
  const OrgLoading();
}

/// Loaded state
class OrgLoaded extends OrgState {
  final Organization? currentOrganization;
  final List<Organization> organizations;

  const OrgLoaded({
    this.currentOrganization,
    this.organizations = const [],
  });

  @override
  List<Object?> get props => [currentOrganization, organizations];
}

/// Error state
class OrgError extends OrgState {
  final String message;

  const OrgError(this.message);

  @override
  List<Object?> get props => [message];
}

