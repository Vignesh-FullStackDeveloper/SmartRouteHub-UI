import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/bus_service.dart';
import '../../services/student_service.dart';
import '../../services/trip_service.dart';
import '../../services/driver_service.dart';
import 'admin_dashboard_event.dart';
import 'admin_dashboard_state.dart';

/// Admin dashboard BLoC
class AdminDashboardBloc
    extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final BusService _busService;
  final StudentService _studentService;
  final TripService _tripService;
  final DriverService _driverService;

  AdminDashboardBloc({
    BusService? busService,
    StudentService? studentService,
    TripService? tripService,
    DriverService? driverService,
  })  : _busService = busService ?? BusService(),
        _studentService = studentService ?? StudentService(),
        _tripService = tripService ?? TripService(),
        _driverService = driverService ?? DriverService(),
        super(const AdminDashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());
    try {
      final buses = await _busService.getBusesByOrganization(event.organizationId);
      final students = await _studentService.getStudentsByOrganization(event.organizationId);
      final activeTrips = await _tripService.getActiveTrips(event.organizationId);
      final drivers = await _driverService.getDriversByOrganization(event.organizationId);
      final driversOnline = drivers.where((d) => d.isActive).length;

      emit(AdminDashboardLoaded(
        totalBuses: buses.length,
        totalStudents: students.length,
        activeTrips: activeTrips.length,
        driversOnline: driversOnline,
        tripsInProgress: activeTrips,
      ));
    } catch (e) {
      emit(AdminDashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<AdminDashboardState> emit,
  ) async {
    await _onLoadDashboardData(LoadDashboardData(event.organizationId), emit);
  }
}

