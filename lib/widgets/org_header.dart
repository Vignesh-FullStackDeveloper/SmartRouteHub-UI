import 'package:flutter/material.dart';
import '../models/organization.dart';
import '../models/user.dart';

/// Organization header widget
/// Displays organization logo, name, and user role
class OrgHeader extends StatelessWidget {
  final Organization? organization;
  final UserRole? role;

  const OrgHeader({
    super.key,
    this.organization,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    if (organization == null) {
      return const SizedBox.shrink();
    }

    // Parse primary color
    Color primaryColor;
    try {
      primaryColor = Color(int.parse(
        organization!.primaryColor.replaceFirst('#', '0xFF'),
      ));
    } catch (e) {
      primaryColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: organization!.logo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      organization!.logo!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildLogoPlaceholder(),
                    ),
                  )
                : _buildLogoPlaceholder(),
          ),
          const SizedBox(width: 12),
          // Organization name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  organization!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (role != null)
                  Text(
                    _getRoleLabel(role!),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return const Icon(
      Icons.school,
      color: Colors.grey,
      size: 24,
    );
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.driver:
        return 'Driver';
      case UserRole.parent:
        return 'Parent';
    }
  }
}

