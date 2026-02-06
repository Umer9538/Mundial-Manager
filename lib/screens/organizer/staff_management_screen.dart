import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/staff_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/staff_assignment.dart';
import '../../models/user.dart';
import '../../widgets/common/gradient_scaffold.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../providers/crowd_provider.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    await staffProvider.initialize('current_event');
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Staff Management',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.softTealBlue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(text: 'All Staff'),
            Tab(text: 'Assignments'),
            Tab(text: 'Zones'),
          ],
        ),
      ),
      body: Consumer<StaffProvider>(
        builder: (context, staffProvider, _) {
          if (staffProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.softTealBlue),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _AllStaffTab(staffProvider: staffProvider),
              _AssignmentsTab(staffProvider: staffProvider),
              _ZoneCoverageTab(staffProvider: staffProvider),
            ],
          );
        },
      ),
    );
  }
}

// ==================== ALL STAFF TAB ====================
class _AllStaffTab extends StatelessWidget {
  final StaffProvider staffProvider;

  const _AllStaffTab({required this.staffProvider});

  @override
  Widget build(BuildContext context) {
    final allStaff = staffProvider.allStaff;

    if (allStaff.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'No staff members found',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.white54),
            ),
            const SizedBox(height: 8),
            Text(
              'Security and emergency staff will appear here',
              style: GoogleFonts.roboto(fontSize: 13, color: Colors.white38),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => staffProvider.refresh(),
      color: AppColors.softTealBlue,
      backgroundColor: AppColors.deepNavyBlue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: allStaff.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _StaffSummaryCard(staffProvider: staffProvider);
          }

          final staff = allStaff[index - 1];
          final assignment = staffProvider.getAssignmentForStaff(staff.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _StaffMemberCard(
              staff: staff,
              assignment: assignment,
              onAssign: () => _showAssignDialog(context, staff),
            ),
          );
        },
      ),
    );
  }

  void _showAssignDialog(BuildContext context, User staff) {
    String? selectedZoneId;
    final zones = Provider.of<CrowdProvider>(context, listen: false).allZones;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A3A5C), Color(0xFF0F253D)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assign Staff',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Staff info
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: staff.role == 'security'
                          ? AppColors.blue.withOpacity(0.2)
                          : AppColors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      staff.role == 'security'
                          ? Icons.security
                          : Icons.medical_services,
                      color: staff.role == 'security'
                          ? AppColors.blue
                          : AppColors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        staff.roleDisplayName,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Select Zone',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              // Zone selection
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x26FFFFFF)),
                ),
                child: DropdownButton<String>(
                  value: selectedZoneId,
                  hint: Text(
                    'Choose a zone',
                    style: GoogleFonts.roboto(
                      color: Colors.white38,
                      fontSize: 16,
                    ),
                  ),
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1A3A5C),
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.white54),
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  items: zones.map((zone) {
                    final assignedCount =
                        staffProvider.getAssignmentsForZone(zone.id).length;
                    return DropdownMenuItem(
                      value: zone.id,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(zone.name),
                          Text(
                            '$assignedCount staff',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setSheetState(() => selectedZoneId = value);
                  },
                ),
              ),
              const SizedBox(height: 24),
              CustomButton.primary(
                text: 'Assign to Zone',
                icon: Icons.assignment_ind,
                onPressed: selectedZoneId == null
                    ? null
                    : () async {
                        final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false);
                        final zone = zones
                            .firstWhere((z) => z.id == selectedZoneId);

                        final success =
                            await staffProvider.assignStaffToZone(
                          staffId: staff.id,
                          staffName: staff.name,
                          staffRole: staff.role,
                          zoneId: zone.id,
                          zoneName: zone.name,
                          assignedBy: authProvider.currentUser!.id,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? '${staff.name} assigned to ${zone.name}'
                                  : 'Failed to assign staff'),
                              backgroundColor:
                                  success ? AppColors.green : AppColors.red,
                            ),
                          );
                        }
                      },
              ),
              const SizedBox(height: 12),
              CustomButton.secondary(
                text: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffSummaryCard extends StatelessWidget {
  final StaffProvider staffProvider;

  const _StaffSummaryCard({required this.staffProvider});

  @override
  Widget build(BuildContext context) {
    final stats = staffProvider.assignmentStats;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Staff Overview',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatItem(
                  label: 'Security',
                  value: '${staffProvider.securityStaff.length}',
                  color: AppColors.blue,
                  icon: Icons.security,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  label: 'Emergency',
                  value: '${staffProvider.emergencyStaff.length}',
                  color: AppColors.red,
                  icon: Icons.medical_services,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  label: 'Assigned',
                  value: '${stats['active'] ?? 0}',
                  color: AppColors.green,
                  icon: Icons.assignment_turned_in,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  label: 'Available',
                  value: '${stats['unassigned'] ?? 0}',
                  color: AppColors.orange,
                  icon: Icons.person_search,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 11,
              color: Colors.white54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StaffMemberCard extends StatelessWidget {
  final User staff;
  final StaffAssignment? assignment;
  final VoidCallback onAssign;

  const _StaffMemberCard({
    required this.staff,
    this.assignment,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final isAssigned = assignment != null;
    final roleColor =
        staff.role == 'security' ? AppColors.blue : AppColors.red;

    return GlassCardWithIndicator(
      indicatorColor: isAssigned ? AppColors.green : AppColors.orange,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              staff.role == 'security'
                  ? Icons.security
                  : Icons.medical_services,
              color: roleColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  staff.roleDisplayName,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
                if (isAssigned) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 12, color: AppColors.green),
                      const SizedBox(width: 4),
                      Text(
                        assignment!.zoneName,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onAssign,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isAssigned
                    ? AppColors.softTealBlue.withOpacity(0.15)
                    : AppColors.softTealBlue,
                borderRadius: BorderRadius.circular(20),
                border: isAssigned
                    ? Border.all(
                        color: AppColors.softTealBlue.withOpacity(0.4))
                    : null,
              ),
              child: Text(
                isAssigned ? 'Reassign' : 'Assign',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ASSIGNMENTS TAB ====================
class _AssignmentsTab extends StatelessWidget {
  final StaffProvider staffProvider;

  const _AssignmentsTab({required this.staffProvider});

  @override
  Widget build(BuildContext context) {
    final assignments = staffProvider.activeAssignments;

    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined,
                size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'No active assignments',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.white54),
            ),
            const SizedBox(height: 8),
            Text(
              'Assign staff to zones from the All Staff tab',
              style: GoogleFonts.roboto(fontSize: 13, color: Colors.white38),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AssignmentCard(
            assignment: assignment,
            onRemove: () async {
              final success =
                  await staffProvider.removeAssignment(assignment.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Assignment removed'
                        : 'Failed to remove assignment'),
                    backgroundColor:
                        success ? AppColors.green : AppColors.red,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final StaffAssignment assignment;
  final VoidCallback onRemove;

  const _AssignmentCard({
    required this.assignment,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor =
        assignment.staffRole == 'security' ? AppColors.blue : AppColors.red;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  assignment.staffRole == 'security'
                      ? Icons.security
                      : Icons.medical_services,
                  color: roleColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.staffName,
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      assignment.roleDisplayName,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white38, size: 20),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on,
                    size: 16, color: AppColors.green),
                const SizedBox(width: 8),
                Text(
                  assignment.zoneName,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.green,
                  ),
                ),
                const Spacer(),
                Text(
                  _getTimeAgo(assignment.assignedAt),
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

// ==================== ZONE COVERAGE TAB ====================
class _ZoneCoverageTab extends StatelessWidget {
  final StaffProvider staffProvider;

  const _ZoneCoverageTab({required this.staffProvider});

  @override
  Widget build(BuildContext context) {
    final zones = Provider.of<CrowdProvider>(context, listen: false).allZones;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: zones.length,
      itemBuilder: (context, index) {
        final zone = zones[index];
        final zoneAssignments =
            staffProvider.getAssignmentsForZone(zone.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        zone.name,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: zoneAssignments.isEmpty
                            ? AppColors.red.withOpacity(0.15)
                            : AppColors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: zoneAssignments.isEmpty
                              ? AppColors.red.withOpacity(0.4)
                              : AppColors.green.withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        '${zoneAssignments.length} staff',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: zoneAssignments.isEmpty
                              ? AppColors.red
                              : AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${zone.type} | Capacity: ${zone.capacity}',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
                if (zoneAssignments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...zoneAssignments.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              a.staffRole == 'security'
                                  ? Icons.security
                                  : Icons.medical_services,
                              size: 16,
                              color: a.staffRole == 'security'
                                  ? AppColors.blue
                                  : AppColors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              a.staffName,
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              a.roleDisplayName,
                              style: GoogleFonts.roboto(
                                fontSize: 11,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
