import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_org_service.dart';
import 'org_event.dart';
import 'org_state.dart';

/// Organization BLoC
class OrgBloc extends Bloc<OrgEvent, OrgState> {
  final ApiOrgService _orgService;

  OrgBloc({ApiOrgService? orgService})
      : _orgService = orgService ?? ApiOrgService(),
        super(const OrgInitial()) {
    on<LoadOrganizationByCode>(_onLoadOrganizationByCode);
    on<LoadOrganizationById>(_onLoadOrganizationById);
    on<LoadAllOrganizations>(_onLoadAllOrganizations);
    on<SetCurrentOrganization>(_onSetCurrentOrganization);
    on<ClearCurrentOrganization>(_onClearCurrentOrganization);
  }

  Future<void> _onLoadOrganizationByCode(
    LoadOrganizationByCode event,
    Emitter<OrgState> emit,
  ) async {
    emit(const OrgLoading());
    try {
      final org = await _orgService.getOrganizationByCode(event.code);
      emit(OrgLoaded(currentOrganization: org));
    } catch (e) {
      emit(OrgError(e.toString()));
    }
  }

  Future<void> _onLoadOrganizationById(
    LoadOrganizationById event,
    Emitter<OrgState> emit,
  ) async {
    emit(const OrgLoading());
    try {
      final org = await _orgService.getOrganizationById(event.id);
      emit(OrgLoaded(currentOrganization: org));
    } catch (e) {
      emit(OrgError(e.toString()));
    }
  }

  Future<void> _onLoadAllOrganizations(
    LoadAllOrganizations event,
    Emitter<OrgState> emit,
  ) async {
    emit(const OrgLoading());
    try {
      // Note: Backend may not have a "get all organizations" endpoint for regular users
      // This might need to be implemented differently or removed
      emit(const OrgError('Get all organizations not implemented'));
    } catch (e) {
      emit(OrgError(e.toString()));
    }
  }

  void _onSetCurrentOrganization(
    SetCurrentOrganization event,
    Emitter<OrgState> emit,
  ) {
    final currentState = state;
    if (currentState is OrgLoaded) {
      emit(OrgLoaded(
        currentOrganization: event.organization,
        organizations: currentState.organizations,
      ));
    } else {
      emit(OrgLoaded(currentOrganization: event.organization));
    }
  }

  void _onClearCurrentOrganization(
    ClearCurrentOrganization event,
    Emitter<OrgState> emit,
  ) {
    final currentState = state;
    if (currentState is OrgLoaded) {
      emit(OrgLoaded(organizations: currentState.organizations));
    } else {
      emit(const OrgLoaded());
    }
  }
}

