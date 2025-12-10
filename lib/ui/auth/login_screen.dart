import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/org/org_bloc.dart';
import '../../blocs/org/org_event.dart';
import '../../blocs/org/org_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/org_header.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/app_constants.dart';
import '../../models/organization.dart';
import '../../models/user.dart';
import 'create_organization_screen.dart';

/// Unified login screen with tabs for Admin, Driver, and Parent
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Organization? _selectedOrganization;
  String _organizationCode = '';

  // Admin form
  final _adminFormKey = GlobalKey<FormState>();
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _orgCodeController = TextEditingController(text: AppConstants.defaultOrganizationCode);

  // Driver form
  final _driverFormKey = GlobalKey<FormState>();
  final _driverPhoneController = TextEditingController();
  final _driverIdController = TextEditingController();
  final _driverOtpController = TextEditingController();
  bool _driverOtpSent = false;

  // Parent form
  final _parentFormKey = GlobalKey<FormState>();
  final _parentPhoneController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _parentOtpController = TextEditingController();
  final _parentPasswordController = TextEditingController();
  bool _parentOtpSent = false;
  bool _parentUseEmail = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _organizationCode = AppConstants.defaultOrganizationCode;
    _orgCodeController.text = AppConstants.defaultOrganizationCode;
    _loadOrganizations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    _orgCodeController.dispose();
    _driverPhoneController.dispose();
    _driverIdController.dispose();
    _driverOtpController.dispose();
    _parentPhoneController.dispose();
    _parentEmailController.dispose();
    _parentOtpController.dispose();
    _parentPasswordController.dispose();
    super.dispose();
  }

  void _loadOrganizations() {
    context.read<OrgBloc>().add(const LoadAllOrganizations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navigation will be handled by main app
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Organization header (if selected)
              BlocBuilder<OrgBloc, OrgState>(
                builder: (context, orgState) {
                  if (orgState is OrgLoaded && orgState.currentOrganization != null) {
                    return OrgHeader(
                      organization: orgState.currentOrganization,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Login form
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'School Bus Tracker',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Organization selection
                    _buildOrganizationSelector(),
                    const SizedBox(height: 16),
                    // Tabs
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Admin'),
                        Tab(text: 'Driver'),
                        Tab(text: 'Parent'),
                      ],
                    ),
                    // Tab views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAdminLogin(),
                          _buildDriverLogin(),
                          _buildParentLogin(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationSelector() {
    return BlocBuilder<OrgBloc, OrgState>(
      builder: (context, state) {
        if (state is OrgLoaded) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Organization Code'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Organization>(
                        decoration: const InputDecoration(
                          hintText: 'Select or enter code',
                          border: OutlineInputBorder(),
                        ),
                        items: state.organizations
                            .map((org) => DropdownMenuItem(
                                  value: org,
                                  child: Text('${org.name} (${org.code})'),
                                ))
                            .toList(),
                        onChanged: (org) {
                          setState(() {
                            _selectedOrganization = org;
                            _organizationCode = org?.code ?? '';
                          });
                          if (org != null) {
                            context.read<OrgBloc>().add(
                                  SetCurrentOrganization(org),
                                );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: _orgCodeController,
                        decoration: const InputDecoration(
                          hintText: 'Code',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _organizationCode = value;
                            _selectedOrganization = null;
                          });
                          if (value.isNotEmpty) {
                            context.read<OrgBloc>().add(
                                  LoadOrganizationByCode(value),
                                );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAdminLogin() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _adminFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dummy credentials hint
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Dummy Admin Login',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[900],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: email@test.com\nPassword: password\nOrg Code: ${AppConstants.defaultOrganizationCode}',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _adminEmailController,
                decoration: InputDecoration(
                  labelText: 'Email or Phone',
                  hintText: 'email@test.com',
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email or phone is required';
                  }
                  return null;
                },
                onTap: () {
                  if (_adminEmailController.text.isEmpty) {
                    _adminEmailController.text = 'email@test.com';
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adminPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter any password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return PrimaryButton(
                    text: 'Login as Admin',
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      if (_adminFormKey.currentState!.validate() &&
                          _organizationCode.isNotEmpty) {
                        context.read<AuthBloc>().add(
                              AdminLoginRequested(
                                organizationCode: _organizationCode,
                                emailOrPhone: _adminEmailController.text,
                                password: _adminPasswordController.text,
                              ),
                            );
                      } else if (_organizationCode.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select or enter organization code'),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              SecondaryButton(
                text: 'Create New Organization',
                icon: Icons.add,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateOrganizationScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverLogin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _driverFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _driverPhoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _driverIdController,
              decoration: const InputDecoration(
                labelText: 'Driver ID (Optional)',
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 16),
            if (_driverOtpSent) ...[
              TextFormField(
                controller: _driverOtpController,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'Enter 123456',
                ),
                keyboardType: TextInputType.number,
                validator: Validators.validateOtp,
              ),
              const SizedBox(height: 16),
            ],
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (!_driverOtpSent) {
                  return PrimaryButton(
                    text: 'Send OTP',
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      if (_driverFormKey.currentState!.validate() &&
                          _organizationCode.isNotEmpty) {
                        context.read<AuthBloc>().add(
                              SendOtpRequested(_driverPhoneController.text),
                            );
                        setState(() {
                          _driverOtpSent = true;
                        });
                      }
                    },
                  );
                }
                return PrimaryButton(
                  text: 'Login as Driver',
                  isLoading: state is AuthLoading,
                  onPressed: () {
                    if (_driverFormKey.currentState!.validate() &&
                        _organizationCode.isNotEmpty) {
                      context.read<AuthBloc>().add(
                            DriverLoginRequested(
                              organizationCode: _organizationCode,
                              phone: _driverPhoneController.text,
                              driverId: _driverIdController.text.isEmpty
                                  ? null
                                  : _driverIdController.text,
                              otp: _driverOtpController.text,
                            ),
                          );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentLogin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _parentFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Phone + OTP'),
                    selected: !_parentUseEmail,
                    onSelected: (selected) {
                      setState(() {
                        _parentUseEmail = !selected;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Email + Password'),
                    selected: _parentUseEmail,
                    onSelected: (selected) {
                      setState(() {
                        _parentUseEmail = selected;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_parentUseEmail) ...[
              TextFormField(
                controller: _parentPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 16),
              if (_parentOtpSent) ...[
                TextFormField(
                  controller: _parentOtpController,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    prefixIcon: Icon(Icons.lock),
                    hintText: 'Enter 123456',
                  ),
                  keyboardType: TextInputType.number,
                  validator: Validators.validateOtp,
                ),
                const SizedBox(height: 16),
              ],
            ] else ...[
              TextFormField(
                controller: _parentEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _parentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),
            ],
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (!_parentUseEmail && !_parentOtpSent) {
                  return PrimaryButton(
                    text: 'Send OTP',
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      if (_parentFormKey.currentState!.validate() &&
                          _organizationCode.isNotEmpty) {
                        context.read<AuthBloc>().add(
                              SendOtpRequested(_parentPhoneController.text),
                            );
                        setState(() {
                          _parentOtpSent = true;
                        });
                      }
                    },
                  );
                }
                return PrimaryButton(
                  text: 'Login as Parent',
                  isLoading: state is AuthLoading,
                  onPressed: () {
                    if (_parentFormKey.currentState!.validate() &&
                        _organizationCode.isNotEmpty) {
                      context.read<AuthBloc>().add(
                            ParentLoginRequested(
                              organizationCode: _organizationCode,
                              phone: _parentUseEmail
                                  ? null
                                  : _parentPhoneController.text,
                              email: _parentUseEmail
                                  ? _parentEmailController.text
                                  : null,
                              otp: _parentUseEmail
                                  ? null
                                  : _parentOtpController.text,
                              password: _parentUseEmail
                                  ? _parentPasswordController.text
                                  : null,
                            ),
                          );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

