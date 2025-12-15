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
import '../../models/organization.dart';
import 'create_organization_screen.dart';

/// Simplified login screen with single form
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orgCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Organization? _selectedOrganization;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  @override
  void dispose() {
    _orgCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
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
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      // App Title
                      const Text(
                        'School Bus Tracker',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Organization selector
                      _buildOrganizationSelector(),
                      const SizedBox(height: 24),
                      // Login form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _orgCodeController,
                              decoration: const InputDecoration(
                                labelText: 'Organization Code *',
                                hintText: 'Enter organization code',
                                prefixIcon: Icon(Icons.business),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Organization code is required';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _selectedOrganization = null;
                                });
                                // Removed API call on every keystroke - unnecessary
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                hintText: 'Enter your email',
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password *',
                                hintText: 'Enter your password',
                                prefixIcon: Icon(Icons.lock),
                              ),
                              obscureText: true,
                              validator: Validators.validatePassword,
                            ),
                            const SizedBox(height: 32),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                return PrimaryButton(
                                  text: 'Sign In',
                                  isLoading: state is AuthLoading,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      final orgCode = _orgCodeController.text.trim();
                                      if (orgCode.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Please enter organization code'),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        return;
                                      }
                                      context.read<AuthBloc>().add(
                                            AdminLoginRequested(
                                              organizationCode: orgCode,
                                              emailOrPhone: _emailController.text.trim(),
                                              password: _passwordController.text,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationSelector() {
    return BlocBuilder<OrgBloc, OrgState>(
      builder: (context, state) {
        if (state is OrgLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Organization',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Organization>(
                      value: _selectedOrganization,
                      decoration: const InputDecoration(
                        hintText: 'Select organization',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
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
                          if (org != null) {
                            _orgCodeController.text = org.code;
                          }
                        });
                        if (org != null) {
                          context.read<OrgBloc>().add(
                                SetCurrentOrganization(org),
                              );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
