import 'package:equatable/equatable.dart';
import '../../models/organization.dart';

/// Organization events
abstract class OrgEvent extends Equatable {
  const OrgEvent();

  @override
  List<Object?> get props => [];
}

/// Load organization by code
class LoadOrganizationByCode extends OrgEvent {
  final String code;

  const LoadOrganizationByCode(this.code);

  @override
  List<Object?> get props => [code];
}

/// Load organization by ID
class LoadOrganizationById extends OrgEvent {
  final String id;

  const LoadOrganizationById(this.id);

  @override
  List<Object?> get props => [id];
}

/// Load all organizations
class LoadAllOrganizations extends OrgEvent {
  const LoadAllOrganizations();
}

/// Set current organization
class SetCurrentOrganization extends OrgEvent {
  final Organization organization;

  const SetCurrentOrganization(this.organization);

  @override
  List<Object?> get props => [organization];
}

/// Clear current organization
class ClearCurrentOrganization extends OrgEvent {
  const ClearCurrentOrganization();
}
