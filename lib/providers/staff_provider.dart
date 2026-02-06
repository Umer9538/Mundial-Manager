import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff_assignment.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class StaffProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  List<StaffAssignment> _assignments = [];
  List<User> _securityStaff = [];
  List<User> _emergencyStaff = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _assignmentSubscription;
  String? _currentEventId;

  List<StaffAssignment> get assignments => _assignments;
  List<User> get securityStaff => _securityStaff;
  List<User> get emergencyStaff => _emergencyStaff;
  List<User> get allStaff => [..._securityStaff, ..._emergencyStaff];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get active assignments only
  List<StaffAssignment> get activeAssignments {
    return _assignments.where((a) => a.isActive).toList();
  }

  // Get staff assignments
  List<StaffAssignment> getStaffAssignments() {
    return _assignments;
  }

  // Get assignments for a specific zone
  List<StaffAssignment> getAssignmentsForZone(String zoneId) {
    return _assignments.where((a) => a.zoneId == zoneId && a.isActive).toList();
  }

  // Get assignment for a specific staff member
  StaffAssignment? getAssignmentForStaff(String staffId) {
    try {
      return _assignments.firstWhere(
        (a) => a.staffId == staffId && a.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  // Get unassigned staff members
  List<User> get unassignedStaff {
    final assignedStaffIds = activeAssignments.map((a) => a.staffId).toSet();
    return allStaff.where((s) => !assignedStaffIds.contains(s.id)).toList();
  }

  // Initialize staff provider
  Future<void> initialize(String eventId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentEventId = eventId;

      // Load staff users and assignments in parallel
      await Future.wait([
        _loadStaffUsers(),
        _loadAssignmentsFromFirestore(eventId),
      ]);

      // Start real-time updates
      _startRealTimeUpdates(eventId);
    } catch (e) {
      _errorMessage = 'Failed to load staff data';
      debugPrint('Error initializing staff provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load staff users from AuthService
  Future<void> _loadStaffUsers() async {
    try {
      final results = await Future.wait([
        _authService.getUsersByRole('security'),
        _authService.getUsersByRole('emergency'),
      ]);

      _securityStaff = results[0];
      _emergencyStaff = results[1];
    } catch (e) {
      debugPrint('Error loading staff users: $e');
    }
  }

  // Load assignments from Firestore
  Future<void> _loadAssignmentsFromFirestore(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('staff_assignments')
          .where('eventId', isEqualTo: eventId)
          .orderBy('assignedAt', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _assignments = snapshot.docs.map((doc) {
          return StaffAssignment.fromJson({
            'id': doc.id,
            ...doc.data(),
          });
        }).toList();
      }
    } catch (e) {
      debugPrint('Error loading assignments from Firestore: $e');
    }
  }

  // Start real-time updates
  void _startRealTimeUpdates(String eventId) {
    _assignmentSubscription?.cancel();
    _assignmentSubscription = _firestore
        .collection('staff_assignments')
        .where('eventId', isEqualTo: eventId)
        .orderBy('assignedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _assignments = snapshot.docs.map((doc) {
        return StaffAssignment.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
      notifyListeners();
    });
  }

  // Assign staff to a zone
  Future<bool> assignStaffToZone({
    required String staffId,
    required String staffName,
    required String staffRole,
    required String zoneId,
    required String zoneName,
    required String assignedBy,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentEventId == null) {
        _errorMessage = 'No event selected';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final now = DateTime.now();
      final newAssignment = StaffAssignment(
        id: '',
        eventId: _currentEventId!,
        staffId: staffId,
        staffName: staffName,
        staffRole: staffRole,
        zoneId: zoneId,
        zoneName: zoneName,
        assignedBy: assignedBy,
        assignedAt: now,
        updatedAt: now,
        isActive: true,
      );

      // Deactivate any existing active assignment for this staff
      final existingAssignment = getAssignmentForStaff(staffId);
      if (existingAssignment != null) {
        await _firestore
            .collection('staff_assignments')
            .doc(existingAssignment.id)
            .update({
          'isActive': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Create new assignment
      final docRef = await _firestore
          .collection('staff_assignments')
          .add({
        ...newAssignment.toJson(),
        'assignedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add to local list
      final assignmentWithId = newAssignment.copyWith(id: docRef.id);
      _assignments.insert(0, assignmentWithId);

      // Remove old assignment from local list
      if (existingAssignment != null) {
        _assignments.removeWhere((a) => a.id == existingAssignment.id);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to assign staff: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reassign staff to a different zone
  Future<bool> reassignStaff({
    required String assignmentId,
    required String newZoneId,
    required String newZoneName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _assignments.indexWhere((a) => a.id == assignmentId);
      if (index == -1) {
        _errorMessage = 'Assignment not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final existing = _assignments[index];

      // Deactivate old assignment
      await _firestore
          .collection('staff_assignments')
          .doc(assignmentId)
          .update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create new assignment with new zone
      final now = DateTime.now();
      final newAssignment = StaffAssignment(
        id: '',
        eventId: existing.eventId,
        staffId: existing.staffId,
        staffName: existing.staffName,
        staffRole: existing.staffRole,
        zoneId: newZoneId,
        zoneName: newZoneName,
        assignedBy: existing.assignedBy,
        assignedAt: now,
        updatedAt: now,
        isActive: true,
      );

      final docRef = await _firestore
          .collection('staff_assignments')
          .add({
        ...newAssignment.toJson(),
        'assignedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local list
      _assignments.removeAt(index);
      _assignments.insert(0, newAssignment.copyWith(id: docRef.id));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to reassign staff: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Remove an assignment (deactivate)
  Future<bool> removeAssignment(String assignmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore
          .collection('staff_assignments')
          .doc(assignmentId)
          .update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final index = _assignments.indexWhere((a) => a.id == assignmentId);
      if (index != -1) {
        _assignments[index] = _assignments[index].copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove assignment: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Refresh data
  Future<void> refresh() async {
    if (_currentEventId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadStaffUsers(),
        _loadAssignmentsFromFirestore(_currentEventId!),
      ]);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to refresh staff data';
      debugPrint('Error refreshing staff data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get assignment statistics
  Map<String, int> get assignmentStats {
    return {
      'total': _assignments.length,
      'active': activeAssignments.length,
      'securityAssigned': activeAssignments
          .where((a) => a.staffRole == 'security')
          .length,
      'emergencyAssigned': activeAssignments
          .where((a) => a.staffRole == 'emergency')
          .length,
      'unassigned': unassignedStaff.length,
    };
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _assignmentSubscription?.cancel();
    super.dispose();
  }
}
