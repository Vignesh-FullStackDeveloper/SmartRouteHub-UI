import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/org/org_bloc.dart';
import '../../widgets/primary_button.dart';
import '../../core/utils/validators.dart';

/// Screen for creating a new organization and admin user
class CreateOrganizationScreen extends StatefulWidget {
  const CreateOrganizationScreen({super.key});

  @override
  State<CreateOrganizationScreen> createState() =>
      _CreateOrganizationScreenState();
}

class _CreateOrganizationScreenState extends State<CreateOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController();
  final _orgCodeController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _adminNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPhoneController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _adminConfirmPasswordController = TextEditingController();
  String _selectedColor = '#2196F3';
  bool _createAdmin = true; // Default to creating admin

  final List<String> _colorOptions = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#9C27B0', // Purple
    '#F44336', // Red
    '#00BCD4', // Cyan
  ];

  @override
  void dispose() {
    _orgNameController.dispose();
    _orgCodeController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _addressController.dispose();
    _adminNameController.dispose();
    _adminEmailController.dispose();
    _adminPhoneController.dispose();
    _adminPasswordController.dispose();
    _adminConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Organization'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Organization Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _orgNameController,
                  decoration: const InputDecoration(
                    labelText: 'Organization Name',
                    prefixIcon: Icon(Icons.school),
                  ),
                  validator: (value) =>
                      Validators.validateRequired(value, 'Organization name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _orgCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Organization Code',
                    prefixIcon: Icon(Icons.tag),
                    helperText: 'Unique code for your organization',
                  ),
                  validator: (value) =>
                      Validators.validateRequired(value, 'Organization code'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Email (Optional)',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      return Validators.validateEmail(value);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Phone (Optional)',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address (Optional)',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text('Primary Color'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _colorOptions.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == color
                                ? Colors.black
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: _selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                // Admin Creation Toggle
                Card(
                  child: CheckboxListTile(
                    title: const Text(
                      'Create Admin User',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Create an admin account for this organization',
                    ),
                    value: _createAdmin,
                    onChanged: (value) {
                      setState(() {
                        _createAdmin = value ?? true;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Admin Fields (shown conditionally)
                if (_createAdmin) ...[
                  const Text(
                    'Admin Account Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _adminNameController,
                    decoration: const InputDecoration(
                      labelText: 'Admin Name *',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: _createAdmin
                        ? (value) =>
                            Validators.validateRequired(value, 'Admin name')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _adminEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Admin Email *',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _createAdmin
                        ? Validators.validateEmail
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _adminPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Admin Phone (Optional)',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _adminPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Password *',
                      prefixIcon: Icon(Icons.lock),
                      helperText: 'Minimum 6 characters',
                    ),
                    obscureText: true,
                    validator: _createAdmin
                        ? Validators.validatePassword
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _adminConfirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password *',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: _createAdmin
                        ? (value) {
                            if (value != _adminPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      text: _createAdmin
                          ? 'Create Organization & Login'
                          : 'Create Organization',
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_createAdmin) {
                            // Create organization with admin
                            context.read<AuthBloc>().add(
                                  CreateOrganizationAndAdminRequested(
                                    organizationName: _orgNameController.text,
                                    organizationCode: _orgCodeController.text,
                                    adminName: _adminNameController.text,
                                    adminEmail: _adminEmailController.text,
                                    adminPhone: _adminPhoneController.text.isEmpty
                                        ? null
                                        : _adminPhoneController.text,
                                    adminPassword: _adminPasswordController.text,
                                    primaryColor: _selectedColor,
                                    contactEmail: _contactEmailController.text.isEmpty
                                        ? null
                                        : _contactEmailController.text,
                                    contactPhone: _contactPhoneController.text.isEmpty
                                        ? null
                                        : _contactPhoneController.text,
                                    address: _addressController.text.isEmpty
                                        ? null
                                        : _addressController.text,
                                  ),
                                );
                          } else {
                            // TODO: Create organization without admin
                            // For now, show message that admin creation is required
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please enable admin creation to continue'),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

