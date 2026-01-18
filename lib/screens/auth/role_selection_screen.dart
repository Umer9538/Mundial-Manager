import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../core/theme/app_colors.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  final List<RoleOption> _roles = [
    RoleOption(
      role: AppConstants.roleFan,
      title: 'Fan',
      description: 'View venue maps, receive safety alerts, and navigate efficiently',
      icon: Icons.person,
      color: AppColors.info,
    ),
    RoleOption(
      role: AppConstants.roleOrganizer,
      title: 'Event Organizer',
      description: 'Monitor crowds, send alerts, manage staff, and view analytics',
      icon: Icons.manage_accounts,
      color: AppColors.primary,
    ),
    RoleOption(
      role: AppConstants.roleSecurity,
      title: 'Security Team',
      description: 'Report incidents, monitor zones, and coordinate responses',
      icon: Icons.security,
      color: AppColors.warning,
    ),
    RoleOption(
      role: AppConstants.roleEmergency,
      title: 'Emergency Services',
      description: 'View incident locations, update response status, and communicate',
      icon: Icons.medical_services,
      color: AppColors.error,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.how_to_reg,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Choose Your Role',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select the role that best describes your access level',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Role Cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  final roleOption = _roles[index];
                  final isSelected = _selectedRole == roleOption.role;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRole = roleOption.role;
                      });
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: isSelected ? 8 : 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? roleOption.color
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: roleOption.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  roleOption.icon,
                                  color: roleOption.color,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      roleOption.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? roleOption.color
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      roleOption.description,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),

                              // Selection Indicator
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: roleOption.color,
                                  size: 32,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedRole != null
                      ? () {
                    Navigator.of(context).pop(_selectedRole);
                  }
                      : null,
                  child: const Text('Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleOption {
  final String role;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  RoleOption({
    required this.role,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
