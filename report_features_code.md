# Mundial - Feature Implementation with Code

> Each section below maps a **PRD feature requirement** to the **actual code** that implements it.
> Take screenshots from the running app and place them alongside these code snippets in your report.

---

# 1. FAN DASHBOARD

**Login:** `fan@test.com` / `password123`

---

## 1.1 View Venue Map

**Screen:** `lib/screens/fan/venue_map_screen.dart`
**What to screenshot:** Map tab showing heatmap with colored zones and POI markers (First Aid, Food, Prayer, Exit, Entrance)

```dart
// Fan Dashboard navigates to VenueMapScreen via bottom nav
Widget build(BuildContext context) {
  return IndexedStack(
    index: _selectedIndex,
    children: [
      _HomeTab(onNavigate: _onItemTapped, currentEvent: _currentEvent),
      const VenueMapScreen(),        // Tab 1: Map
      const NotificationsScreen(),    // Tab 2: Alerts
      const FanProfileScreen(),       // Tab 3: Profile
    ],
  );
}
```

**Map renders real-time crowd data from Firestore:**
```dart
// venue_map_screen.dart - Lines 56-62
CrowdHeatmap(
  crowdData: crowdProvider.crowdData,   // Real Firestore data
  zones: crowdProvider.allZones,         // Real Firestore zones
  onZoneTap: (zone) {
    _showZoneDetails(context, zone.id, crowdProvider);
  },
),
```

**Zone details bottom sheet shows live occupancy:**
```dart
// venue_map_screen.dart - Lines 322-378
void _showZoneDetails(BuildContext context, String zoneId, CrowdProvider crowdProvider) {
  final zone = crowdProvider.getZone(zoneId);
  final density = crowdProvider.getZoneDensity(zoneId);

  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      child: Column(
        children: [
          Text(zone.name),
          _InfoRow(label: 'Population', value: '${density.currentPopulation}/${density.capacity}'),
          _InfoRow(label: 'Occupancy', value: '${density.occupancyPercentageRounded}%'),
          _InfoRow(label: 'Density', value: '${density.densityPerSqMeter.toStringAsFixed(1)} p/m²'),
        ],
      ),
    ),
  );
}
```

---

## 1.2 Receive Live Alerts

**Screen:** `lib/screens/fan/notifications_screen.dart`
**What to screenshot:** Alerts tab showing list of colored alert cards with severity indicators

```dart
// notifications_screen.dart - Loads alerts from Firestore via AlertProvider
Consumer<AlertProvider>(
  builder: (context, alertProvider, _) {
    final allAlerts = alertProvider.getAlertsForRole('fan');  // Filtered for fan role
    final filteredAlerts = _filterAlerts(allAlerts);

    return ListView.builder(
      itemCount: filteredAlerts.length,
      itemBuilder: (context, index) {
        return _AlertCard(
          alert: filteredAlerts[index],
          onTap: () => _showAlertDetails(context, filteredAlerts[index], alertProvider),
        );
      },
    );
  },
),
```

**Alert detail bottom sheet with action buttons:**
```dart
// notifications_screen.dart - Lines 153-351
void _showAlertDetails(BuildContext context, dynamic alert, AlertProvider alertProvider) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      children: [
        Text('${_getSeverityLabel(alert.severity)}: ${alert.typeDisplayName}'),
        Text(alert.message),

        // Acknowledge Button
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await alertProvider.dismissAlert(alert.id);
          },
          child: Text('Acknowledge'),
        ),

        // Notify Emergency Button
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await alertProvider.sendEmergencyAlert(
              eventId: alert.eventId,
              createdBy: user.id,
              createdByName: user.name,
              message: 'Fan reported emergency for: ${alert.typeDisplayName}',
            );
          },
          child: Text('Notify Emergency'),
        ),
      ],
    ),
  );
}
```

**Also shows on Home tab with badge count:**
```dart
// fan_dashboard.dart - Lines 156-161
_NavItem(
  icon: Icons.notifications_outlined,
  label: 'Alerts',
  badge: Consumer<AlertProvider>(
    builder: (context, alertProvider, _) {
      final count = alertProvider.getAlertsForRole('fan').length;
      if (count == 0) return const SizedBox.shrink();
      return _BadgeCount(count: count);
    },
  ),
),
```

---

## 1.3 Share Location

**Screen:** `lib/screens/fan/fan_dashboard.dart`
**What to screenshot:** Home tab showing the "Share My Location" toggle button (green when ON)

```dart
// fan_dashboard.dart - Lines 572-621
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    final isSharing = authProvider.currentUser?.locationSharingEnabled ?? false;
    return GestureDetector(
      onTap: () async {
        await authProvider.toggleLocationSharing();
        if (context.mounted && authProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.errorMessage!)),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSharing ? AppColors.green.withOpacity(0.2) : Colors.white.withOpacity(0.08),
          border: Border.all(color: isSharing ? AppColors.green : Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSharing ? Icons.location_on : Icons.location_off_outlined),
            Text(isSharing ? 'Location Sharing: ON' : 'Share My Location'),
          ],
        ),
      ),
    );
  },
),
```

**Backend - AuthProvider toggles location via LocationService:**
```dart
// auth_provider.dart - Lines 451-469
Future<void> toggleLocationSharing() async {
  if (_currentUser == null) return;
  final newValue = !_currentUser!.locationSharingEnabled;

  if (newValue) {
    final success = await _locationService.startSharing(_currentUser!.id);
    if (!success) {
      _errorMessage = 'Location permission denied. Please enable it in Settings.';
      notifyListeners();
      return;
    }
  } else {
    await _locationService.stopSharing();
  }

  await updateProfile(locationSharingEnabled: newValue);
}
```

---

## 1.4 Report Incident (Fan)

**Screen:** `lib/screens/common/report_incident_screen.dart`
**What to screenshot:** Report Incident form with type selector, severity selector, description field, photo upload

```dart
// report_incident_screen.dart - Lines 110-194
Future<void> _submitReport() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final incidentProvider = Provider.of<IncidentProvider>(context, listen: false);
  final user = authProvider.currentUser!;

  // Upload images to Firebase Storage if any
  List<String>? imageUrls;
  if (_images.isNotEmpty) {
    final storageService = StorageService();
    final imageFiles = _images.map((x) => File(x.path)).toList();
    imageUrls = await storageService.uploadIncidentImages(
      incidentId: incidentId,
      imageFiles: imageFiles,
    );
  }

  // Submit incident to Firestore
  final success = await incidentProvider.reportIncident(
    eventId: event?.id ?? '',
    reportedBy: user.id,
    reportedByName: user.name,
    location: incidentLocation,
    type: _selectedType,           // medical, security, overcrowding, etc.
    description: _descriptionController.text.trim(),
    severity: _selectedSeverity,   // low, medium, high, critical
    imageUrls: imageUrls,
  );

  if (success) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incident reported successfully')),
    );
  }
}
```

---

---

# 2. SECURITY TEAM DASHBOARD

**Login:** `security@test.com` / `password123`

---

## 2.1 Receive & Respond to Alerts

**Screen:** `lib/screens/security/security_dashboard.dart`
**What to screenshot:** Dashboard tab showing quick action cards + Alerts tab with alert list

**Dashboard quick actions wired to real navigation:**
```dart
// security_dashboard.dart - _DashboardTab
_QuickActionCard(
  icon: Icons.visibility,
  title: 'Monitor Crowd',
  subtitle: 'View real-time density',
  color: AppColors.blue,
  onTap: () => onNavigate(1),        // Navigate to Zones tab
),
_QuickActionCard(
  icon: Icons.notification_important,
  title: 'View Alerts',
  subtitle: '${activeAlerts.length} active',
  color: AppColors.orange,
  onTap: () => onNavigate(2),        // Navigate to Map/Alerts tab
),
_QuickActionCard(
  icon: Icons.group,
  title: 'Team Updates',
  subtitle: 'Communication hub',
  color: AppColors.green,
  onTap: () => context.push('/communication'),  // Opens Communication Hub
),
```

**Alert detail sheet with "Mark Resolved" action:**
```dart
// security_dashboard.dart - _AlertDetailSheet
class _AlertDetailSheet extends StatelessWidget {
  final dynamic alert;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(alert.typeDisplayName),
        Text(alert.message),
        Text('Severity: ${alert.severity}'),
        Text('Created by: ${alert.createdByName}'),

        // Mark Resolved Button
        ElevatedButton(
          onPressed: () async {
            final alertProvider = Provider.of<AlertProvider>(context, listen: false);
            final success = await alertProvider.resolveAlert(alert.id);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(success ? 'Alert resolved' : 'Failed to resolve')),
              );
            }
          },
          child: Text('Mark Resolved'),
        ),
      ],
    );
  }
}
```

---

## 2.2 Report Incidents

**Screen:** `lib/screens/common/report_incident_screen.dart` (shared with Fan)
**What to screenshot:** Report button on Security Dashboard → opens Report Incident form

**Triggered from monitoring panel:**
```dart
// security_dashboard.dart - Monitoring panel Report button
CustomButton.warning(
  text: 'Report',
  icon: Icons.warning_amber,
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportIncidentScreen()),
    );
  },
),
```

---

## 2.3 Monitor Crowd Density

**Screen:** `lib/screens/security/security_dashboard.dart` (Zones tab + Map tab)
**What to screenshot:** Zones tab showing zone cards with density levels, Map tab showing heatmap

**Zones tab loads real data from CrowdProvider:**
```dart
// security_dashboard.dart - _ZonesTab
Consumer<CrowdProvider>(
  builder: (context, crowdProvider, _) {
    final zones = crowdProvider.allZones;

    return ListView.builder(
      itemCount: zones.length,
      itemBuilder: (context, index) {
        final zone = zones[index];
        final density = crowdProvider.getZoneDensity(zone.id);
        final occupancy = density?.occupancyPercentageRounded ?? 0;

        return GlassCard(
          child: Column(
            children: [
              Text(zone.name),
              Text('${density?.currentPopulation ?? 0} / ${zone.capacity}'),
              LinearProgressIndicator(value: occupancy / 100),
              Text('$occupancy% capacity'),
            ],
          ),
        );
      },
    );
  },
),
```

**Map tab shows CrowdHeatmap with incident markers:**
```dart
// security_dashboard.dart - _MapTab
CrowdHeatmap(
  crowdData: crowdProvider.crowdData,
  zones: crowdProvider.allZones,
  incidentMarkers: incidentProvider.activeIncidents.map((incident) {
    return IncidentMapMarker(
      incident: incident,
      onTap: () => _showIncidentDetail(context, incident),
    );
  }).toList(),
),
```

---

---

# 3. EMERGENCY SERVICES DASHBOARD

**Login:** `emergency@test.com` / `password123`

---

## 3.1 View Incident Locations

**Screen:** `lib/screens/emergency/emergency_dashboard.dart` (Map tab)
**What to screenshot:** Map showing incident markers (colored by severity) on the venue map

```dart
// emergency_dashboard.dart - _MapTab builds incident markers on a FlutterMap
FlutterMap(
  options: MapOptions(initialCenter: venueCenter, initialZoom: 16.0),
  children: [
    TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
    MarkerLayer(
      markers: incidentProvider.activeIncidents.map((incident) {
        return Marker(
          point: LatLng(incident.latitude, incident.longitude),
          width: 40, height: 40,
          child: GestureDetector(
            onTap: () {
              // Navigate to Alerts tab to see incident details
              final dashState = context.findAncestorStateOfType<_EmergencyDashboardState>();
              dashState?.setState(() => dashState._selectedIndex = 2);
            },
            child: IncidentMarkerWidget(
              severity: incident.severity,
              type: incident.type,
            ),
          ),
        );
      }).toList(),
    ),
  ],
),
```

---

## 3.2 Update Response Status

**Screen:** `lib/screens/emergency/emergency_dashboard.dart` (Dashboard tab)
**What to screenshot:** Dashboard showing incident cards with status badges (dispatched, on_site, resolved)

**Dispatched teams count from real data:**
```dart
// emergency_dashboard.dart - Dashboard metrics panel
Text(
  '${incidentProvider.getIncidentsByStatus(AppConstants.statusDispatched).length}',
  style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold),
),
Text('Teams Dispatched'),
```

**Incident status display name from model:**
```dart
// Uses incident.statusDisplayName instead of hardcoded text
Text(
  incident.statusDisplayName,  // "Reported", "Dispatched", "On Site", "Resolved"
  style: GoogleFonts.roboto(fontSize: 12, color: statusColor),
),
```

**Evacuation dialog sends real emergency alert to Firestore:**
```dart
// emergency_dashboard.dart - Evacuation action
ElevatedButton(
  onPressed: () async {
    final alertProvider = Provider.of<AlertProvider>(context, listen: false);
    final user = authProvider.currentUser!;

    final success = await alertProvider.sendEmergencyAlert(
      eventId: eventId,
      createdBy: user.id,
      createdByName: user.name,
      message: 'EVACUATION ORDER: All attendees and staff must evacuate immediately.',
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency evacuation alert sent to all users')),
      );
    }
  },
  child: Text('INITIATE EVACUATION'),
),
```

---

## 3.3 Communicate with Organizers

**Screen:** `lib/screens/common/communication_hub_screen.dart`
**What to screenshot:** Communication Hub showing channels (security-ops, emergency-ops, all-staff) with real-time messages

```dart
// communication_hub_screen.dart - Send message to Firestore
Future<void> _sendMessage() async {
  final text = _messageController.text.trim();
  if (text.isEmpty) return;

  final user = authProvider.currentUser;
  _messageController.clear();

  final success = await messageProvider.sendMessage(
    content: text,
    senderId: user.id,
    senderName: user.name,
    senderRole: user.role,
    type: _selectedMessageType,  // 'text', 'alert', 'incident_update'
  );
}
```

**Messages loaded real-time from Firestore via MessageProvider:**
```dart
// message_provider.dart - Real-time stream from Firestore
void _startListeningToMessages() {
  _messagesSubscription = _firestore
      .collection('messages')
      .where('channelId', isEqualTo: _currentChannelId)
      .orderBy('createdAt', descending: false)
      .snapshots()
      .listen((snapshot) {
    _messages = snapshot.docs.map((doc) => Message.fromJson({
      'id': doc.id,
      ...doc.data(),
    })).toList();
    notifyListeners();
  });
}
```

---

---

# 4. EVENT ORGANIZER DASHBOARD

**Login:** `organizer@test.com` / `password123`

---

## 4.1 View Crowd Movement

**Screen:** `lib/screens/organizer/organizer_dashboard.dart` (Crowd tab)
**What to screenshot:** Crowd monitoring tab showing heatmap + zone density cards

```dart
// organizer_dashboard.dart - _CrowdTab
Consumer<CrowdProvider>(
  builder: (context, crowdProvider, _) {
    return Column(
      children: [
        // Real-time heatmap
        SizedBox(
          height: 300,
          child: CrowdHeatmap(
            crowdData: crowdProvider.crowdData,
            zones: crowdProvider.allZones,
          ),
        ),

        // Zone density cards from Firestore
        ...crowdProvider.allZones.map((zone) {
          final density = crowdProvider.getZoneDensity(zone.id);
          return _ZoneDensityCard(
            zoneName: zone.name,
            currentCount: density?.currentPopulation ?? 0,
            capacity: zone.capacity,
            occupancy: density?.occupancyPercentageRounded ?? 0,
          );
        }),
      ],
    );
  },
),
```

---

## 4.2 Send Safety Alerts

**Screen:** `lib/screens/organizer/organizer_dashboard.dart` (Alerts tab)
**What to screenshot:** Create Alert dialog with type, message, severity, target roles

```dart
// organizer_dashboard.dart - Send Alert dialog
Future<void> _showSendAlertDialog(BuildContext context) async {
  showModalBottomSheet(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) => Column(
        children: [
          Text('Send Alert'),

          // Alert type selection (congestion, safety, emergency, info)
          DropdownButton<String>(
            value: selectedType,
            items: ['congestion', 'safety', 'emergency', 'info'].map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) => setSheetState(() => selectedType = value!),
          ),

          // Message input
          TextField(controller: messageController, maxLines: 3),

          // Target roles checkboxes
          CheckboxListTile(title: Text('Fans'), value: targetFans, onChanged: ...),
          CheckboxListTile(title: Text('Security'), value: targetSecurity, onChanged: ...),
          CheckboxListTile(title: Text('Emergency'), value: targetEmergency, onChanged: ...),

          // Send button - saves to Firestore
          ElevatedButton(
            onPressed: () async {
              final success = await alertProvider.sendAlert(
                eventId: _currentEventId!,
                createdBy: user.id,
                createdByName: user.name,
                type: selectedType,
                message: messageController.text,
                severity: selectedSeverity,
                targetRoles: targetRoles,
              );
            },
            child: Text('Send Alert'),
          ),
        ],
      ),
    ),
  );
}
```

---

## 4.3 View Analytics & Reports

**Screen:** `lib/screens/organizer/analytics_screen.dart`
**What to screenshot:** Analytics screen with charts (line charts, bar charts) and date range picker

```dart
// analytics_screen.dart - Loads data from AnalyticsProvider
Future<void> _initializeData() async {
  final event = await DatabaseService().getCurrentActiveEvent();
  final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
  await analyticsProvider.initialize(event?.id ?? '');
}

// Date range picker for filtering
Future<void> _selectDateRange() async {
  final picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime.now().subtract(const Duration(days: 365)),
    lastDate: DateTime.now(),
    initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
  );
}
```

**Charts rendered using fl_chart library with real data:**
```dart
// analytics_screen.dart - Line chart for crowd trends
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: analyticsProvider.crowdTrendData.map((point) {
          return FlSpot(point.x, point.y);
        }).toList(),
        color: AppColors.softTealBlue,
      ),
    ],
  ),
),
```

---

## 4.4 Manage Roles & Zones (Staff Management)

**Screen:** `lib/screens/organizer/staff_management_screen.dart`
**What to screenshot:** Staff Management with 3 tabs: All Staff, Assignments, Zones

**All Staff tab shows users from Firestore:**
```dart
// staff_management_screen.dart - _AllStaffTab
final allStaff = staffProvider.allStaff;  // Real users from Firestore

return ListView.builder(
  itemCount: allStaff.length,
  itemBuilder: (context, index) {
    final staff = allStaff[index];
    final assignment = staffProvider.getAssignmentForStaff(staff.id);

    return _StaffMemberCard(
      staff: staff,
      assignment: assignment,
      onAssign: () => _showAssignDialog(context, staff),
    );
  },
);
```

**Assign Staff to Zone dialog with real zone data:**
```dart
// staff_management_screen.dart - Lines 165-360
void _showAssignDialog(BuildContext context, User staff) {
  String? selectedZoneId;
  final zones = Provider.of<CrowdProvider>(context, listen: false).allZones;

  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      children: [
        Text('Assign Staff'),
        Text('${staff.name} - ${staff.roleDisplayName}'),

        // Zone dropdown from Firestore
        DropdownButton<String>(
          hint: Text('Choose a zone'),
          items: zones.map((zone) {
            final assignedCount = staffProvider.getAssignmentsForZone(zone.id).length;
            return DropdownMenuItem(
              value: zone.id,
              child: Row(
                children: [
                  Text(zone.name),
                  Text('$assignedCount staff'),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setSheetState(() => selectedZoneId = value),
        ),

        // Assign button - saves to Firestore
        CustomButton.primary(
          text: 'Assign to Zone',
          onPressed: selectedZoneId == null ? null : () async {
            final success = await staffProvider.assignStaffToZone(
              staffId: staff.id,
              staffName: staff.name,
              staffRole: staff.role,
              zoneId: zone.id,
              zoneName: zone.name,
              assignedBy: authProvider.currentUser!.id,
            );
          },
        ),
      ],
    ),
  );
}
```

**Zone Coverage tab shows staff per zone:**
```dart
// staff_management_screen.dart - _ZoneCoverageTab
final zones = Provider.of<CrowdProvider>(context).allZones;

return ListView.builder(
  itemCount: zones.length,
  itemBuilder: (context, index) {
    final zone = zones[index];
    final zoneAssignments = staffProvider.getAssignmentsForZone(zone.id);

    return GlassCard(
      child: Column(
        children: [
          Text(zone.name),
          Text('${zone.type} | Capacity: ${zone.capacity}'),
          Text('${zoneAssignments.length} staff assigned'),
          ...zoneAssignments.map((a) => Row(
            children: [
              Icon(a.staffRole == 'security' ? Icons.security : Icons.medical_services),
              Text(a.staffName),
              Text(a.roleDisplayName),
            ],
          )),
        ],
      ),
    );
  },
);
```

**Create Event dialog:**
```dart
// organizer_dashboard.dart - _showCreateEventDialog
void _showCreateEventDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Create New Event'),
      content: Column(
        children: [
          TextField(controller: nameController, decoration: InputDecoration(labelText: 'Event Name')),
          TextField(controller: descController, decoration: InputDecoration(labelText: 'Description')),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            final dbService = DatabaseService();
            await dbService.createEvent(Event(
              id: '',
              name: nameController.text.trim(),
              description: descController.text.trim(),
              venueId: '',
              startDate: DateTime.now(),
              endDate: DateTime.now().add(const Duration(hours: 3)),
              capacity: 0,
              status: 'planned',
            ));
            Navigator.pop(context);
          },
          child: Text('Create'),
        ),
      ],
    ),
  );
}
```

---

---

# 5. AUTHENTICATION SYSTEM (Shared)

**What to screenshot:** Login screen, Register screen, Forgot Password dialog

## 5.1 Login with Email Verification

```dart
// login_screen.dart - _handleLogin
Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final success = await authProvider.login(
    _emailController.text.trim(),
    _passwordController.text,
  );

  if (success) {
    // Save remembered email
    if (_rememberMe) {
      await prefs.setBool(AppConstants.keyRememberMe, true);
      await prefs.setString(AppConstants.keyRememberedEmail, _emailController.text.trim());
    }

    // Route based on email verification status
    if (authProvider.needsEmailVerification) {
      context.go('/email-verification');
    } else {
      context.go(AppRouter.getDashboardRoute(authProvider.userRole!));
    }
  }
}
```

## 5.2 Registration with Role Selection

```dart
// register_screen.dart - _handleRegister
Future<void> _handleRegister() async {
  if (!_formKey.currentState!.validate()) return;

  final success = await authProvider.register(
    email: _emailController.text.trim(),
    name: _nameController.text.trim(),
    password: _passwordController.text,
    role: _selectedRole!,   // fan, organizer, security, emergency
  );

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registration successful!')),
    );
    context.pop(); // Return to login
  }
}
```

## 5.3 Password Reset

```dart
// login_screen.dart - _showForgotPasswordDialog
ElevatedButton(
  onPressed: () async {
    final email = resetEmailController.text.trim();
    final success = await authProvider.resetPassword(email);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success
          ? 'Password reset link sent to $email'
          : 'Failed to send reset email')),
    );
  },
  child: Text('Send Link'),
),
```

---

# 6. DEMO ACCOUNTS FOR TESTING

| Role | Email | Password | Dashboard |
|------|-------|----------|-----------|
| Fan | `fan@test.com` | `password123` | View map, alerts, share location |
| Organizer | `organizer@test.com` | `password123` | Crowd monitoring, send alerts, analytics, staff management |
| Security | `security@test.com` | `password123` | Receive alerts, report incidents, monitor crowd |
| Emergency | `emergency@test.com` | `password123` | View incidents, update status, communicate |

---

# 7. DATA FLOW ARCHITECTURE

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────┐
│   UI Screen   │────▶│    Provider       │────▶│  Firestore    │
│  (StatefulWidget)   │  (ChangeNotifier) │     │  (Cloud DB)   │
└──────────────┘     └──────────────────┘     └──────────────┘
        │                      │                       │
   User taps button     Calls service method     Reads/writes
   Shows loading        Updates state            Real-time streams
   Displays result      notifyListeners()        Server timestamps
```

**Provider Pattern:**
- `AuthProvider` → Login, Register, Logout, Location Sharing
- `CrowdProvider` → Zone data, Crowd density, Real-time updates
- `IncidentProvider` → Report/View incidents, Status updates
- `AlertProvider` → Send/Receive/Resolve alerts
- `StaffProvider` → Staff assignments, Zone coverage
- `AnalyticsProvider` → Charts, Reports, Statistics
- `MessageProvider` → Real-time messaging, Channels

**All data flows through Firestore — zero hardcoded dummy data in production.**
