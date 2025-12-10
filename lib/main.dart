import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/org/org_bloc.dart';
import 'blocs/org/org_event.dart';
import 'blocs/org/org_state.dart';
import 'services/notification_service.dart';
import 'ui/auth/login_screen.dart';
import 'ui/admin/admin_dashboard_screen.dart';
import 'ui/driver/driver_dashboard_screen.dart';
import 'ui/parent/parent_dashboard_screen.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (skip on web to avoid blocking)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      // Firebase not configured yet - app will still work with mock data
      print('Firebase initialization skipped: $e');
    }
  } else {
    print('Firebase initialization skipped on web');
  }

  // Initialize notification service (skip on web due to Firebase compatibility)
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
  } catch (e) {
    print('Notification service initialization skipped: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(const AuthStatusChecked())),
        BlocProvider(create: (_) => OrgBloc()),
      ],
      child: MaterialApp(
        title: 'School Bus Tracker',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const AppNavigator(),
      ),
    );
  }
}

/// Main app navigator that routes based on authentication state
class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthAuthenticated) {
          final user = state.user;
          
          // Load organization for branding (user.organizationId is the UUID)
          // Only load if organizationId is not empty
          if (user.organizationId.isNotEmpty) {
            context.read<OrgBloc>().add(LoadOrganizationById(user.organizationId));
          }

          // Route based on user role
          switch (user.role) {
            case UserRole.admin:
              return AdminDashboardScreen(user: user as AdminUser);
            case UserRole.driver:
              return DriverDashboardScreen(user: user as DriverUser);
            case UserRole.parent:
              return ParentDashboardScreen(user: user as ParentUser);
          }
        }

        // Not authenticated - show login
        return const LoginScreen();
      },
    );
  }
}

