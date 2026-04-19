// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Mundial';

  @override
  String get appNameManager => 'MANAGER';

  @override
  String get appTagline => 'Crowd Management for FIFA World Cup 2026';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginSubtitle => 'Please enter your account details.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginButton => 'Login';

  @override
  String get orRegisterWith => 'or Register With';

  @override
  String get googleSignInComingSoon => 'Google sign-in coming soon';

  @override
  String get facebookSignInComingSoon => 'Facebook sign-in coming soon';

  @override
  String get appleSignInComingSoon => 'Apple sign-in coming soon';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get registerLink => 'Register';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordDesc =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get sendLinkButton => 'Send Link';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get createAccountTitle => 'Create Your Account';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameHint => 'Enter your full name';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Confirm your password';

  @override
  String get selectRoleLabel => 'Select Your Role';

  @override
  String get selectRoleHint => 'Select Role';

  @override
  String get roleFan => 'Fan';

  @override
  String get roleOrganizer => 'Event Organizer';

  @override
  String get roleSecurity => 'Security Team';

  @override
  String get roleEmergency => 'Emergency Services';

  @override
  String get registerButton => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get loginLink => 'Login';

  @override
  String get passwordsMismatch => 'Passwords do not match';

  @override
  String get pleaseSelectRole => 'Please select a role';

  @override
  String get registrationSuccess => 'Registration successful!';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get roleRequired => 'Please select a role';

  @override
  String get verifyEmailTitle => 'Verify Your Email';

  @override
  String get emailSentTo => 'We\'ve sent a verification email to:';

  @override
  String get verifyEmailInstructions =>
      'Please check your inbox and click the verification link to activate your account. If you don\'t see the email, check your spam or junk folder.';

  @override
  String get verifyAndContinue => 'I\'ve Verified, Continue';

  @override
  String get checkingStatus => 'Checking...';

  @override
  String get resendEmail => 'Resend Verification Email';

  @override
  String resendEmailCooldown(int seconds) {
    return 'Resend Email ($seconds s)';
  }

  @override
  String canResendIn(int seconds) {
    return 'You can resend in $seconds seconds';
  }

  @override
  String get verifyEmailHelp =>
      'Having trouble? Make sure to check your spam folder. The email may take a few minutes to arrive.';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get emailNotVerified =>
      'Email not verified yet. Please check your inbox.';

  @override
  String get verificationCheckError => 'Error checking verification status';

  @override
  String get emailSentSuccess => 'Verification email sent!';

  @override
  String get emailSendFailed =>
      'Failed to send verification email. Please try again.';

  @override
  String get selectYourRole => 'Select Your Role';

  @override
  String get chooseYourRole => 'Choose Your Role';

  @override
  String get selectRoleDescription =>
      'Select the role that best describes your access level';

  @override
  String get roleFanDesc =>
      'View venue maps, receive safety alerts, and navigate efficiently';

  @override
  String get roleOrganizerDesc =>
      'Monitor crowds, send alerts, manage staff, and view analytics';

  @override
  String get roleSecurityDesc =>
      'Report incidents, monitor zones, and coordinate responses';

  @override
  String get roleEmergencyDesc =>
      'View incident locations, update response status, and communicate';

  @override
  String get continueButton => 'Continue';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name';
  }

  @override
  String get currentEvent => 'Current Event:';

  @override
  String get noActiveEvent => 'No active event';

  @override
  String get activeAlerts => 'Active Alerts';

  @override
  String get viewAllAlerts => 'View All Alerts';

  @override
  String get viewMap => 'View Map';

  @override
  String get viewAlerts => 'View Alerts';

  @override
  String get reportIncident => 'Report Incident';

  @override
  String get locationSharingOn => 'Location Sharing: ON';

  @override
  String get shareMyLocation => 'Share My Location';

  @override
  String get homeTab => 'Home';

  @override
  String get mapTab => 'Map';

  @override
  String get alertsTab => 'Alerts';

  @override
  String get profileTab => 'Profile';

  @override
  String get viewOnMap => 'View on Map';

  @override
  String get eventMap => 'Event Map';

  @override
  String get liveCrowdMonitoring => 'Live Crowd Monitoring';

  @override
  String get averageDensity => 'Average Density';

  @override
  String currentAvgDensity(int percent) {
    return 'Current Avg. Density';
  }

  @override
  String activeCriticalAlerts(int count) {
    return 'Active Critical Alerts: $count';
  }

  @override
  String get allFilter => 'All';

  @override
  String get reportIssue => 'Report Issue';

  @override
  String get densitySafe => 'Safe (<1.5)';

  @override
  String get densityModerate => 'Moderate';

  @override
  String get densityHigh => 'High';

  @override
  String get densityCritical => 'Critical (>4.5)';

  @override
  String get populationLabel => 'Population';

  @override
  String get occupancyLabel => 'Occupancy';

  @override
  String get densityLabel => 'Density';

  @override
  String get temperatureLabel => 'Temperature';

  @override
  String get weatherLabel => 'Weather';

  @override
  String get statusLabel => 'Status';

  @override
  String get statusSafe => 'Safe';

  @override
  String get statusModerate => 'Moderate';

  @override
  String get statusHighDensity => 'High Density';

  @override
  String get statusCritical => 'Critical';

  @override
  String get peopleAlerts => 'People Alerts';

  @override
  String get noAlertsTitle => 'No alerts at the moment';

  @override
  String get noAlertsSubtitle => 'You\'ll be notified of any safety updates';

  @override
  String get activeFilter => 'Active';

  @override
  String get resolvedFilter => 'Resolved';

  @override
  String get criticalLabel => 'Critical';

  @override
  String get highLabel => 'High';

  @override
  String get moderateLabel => 'Moderate';

  @override
  String get infoLabel => 'Info';

  @override
  String get resolvedLabel => 'Resolved';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String daysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get severityLabel => 'Severity';

  @override
  String get affectedZone => 'Affected Zone';

  @override
  String get allZones => 'All zones';

  @override
  String get acknowledgeButton => 'Acknowledge';

  @override
  String get notifyEmergency => 'Notify Emergency';

  @override
  String get markResolved => 'Mark Resolved';

  @override
  String get alertAcknowledged => 'Alert acknowledged and dismissed';

  @override
  String get alertAcknowledgeFailed => 'Failed to acknowledge alert';

  @override
  String get emergencyNotified => 'Emergency team has been notified';

  @override
  String get emergencyNotifyFailed => 'Failed to notify emergency team';

  @override
  String get alertResolved => 'Alert marked as resolved';

  @override
  String get alertResolveFailed => 'Failed to resolve alert';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get displayPreferences => 'Display Preferences';

  @override
  String get notificationsAlerts => 'Notifications & Alerts';

  @override
  String get languageLocalization => 'Language & Localization';

  @override
  String get privacyAccount => 'Privacy & Account';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get doneButton => 'Done';

  @override
  String get restoreDefaults => 'Restore Defaults';

  @override
  String get seedDemoData => 'Seed Demo Data';

  @override
  String get securedByFirebase => 'Secured by Firebase';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Use dark theme throughout the app';

  @override
  String get textSize => 'Text Size';

  @override
  String get textSizeSmall => 'Small';

  @override
  String get textSizeMedium => 'Medium';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsSubtitle =>
      'Receive push notifications on your device';

  @override
  String get soundLabel => 'Sound';

  @override
  String get soundSubtitle => 'Play sound for new alerts';

  @override
  String get crowdAlerts => 'Crowd Alerts';

  @override
  String get crowdAlertsSubtitle => 'Get notified about crowd density changes';

  @override
  String get emergencyAlerts => 'Emergency Alerts';

  @override
  String get emergencyAlertsSubtitle =>
      'Receive critical emergency notifications';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get locationSharing => 'Location Sharing';

  @override
  String get locationSharingSubtitle =>
      'Share your location for crowd tracking';

  @override
  String get analyticsLabel => 'Analytics';

  @override
  String get analyticsSubtitle => 'Help improve the app with usage data';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get settingsSaved => 'Settings saved successfully';

  @override
  String get settingsRestored => 'Settings restored to defaults';

  @override
  String get seedDataTitle => 'Seed Demo Data';

  @override
  String get seedDataDesc =>
      'This will clear existing data and load fresh demo data (events, zones, crowd density, incidents, alerts, etc.).\n\nYou will be signed out and need to log back in.';

  @override
  String get seedDataButton => 'Seed Data';

  @override
  String seedingFailed(String error) {
    return 'Seeding failed: $error';
  }

  @override
  String get myProfile => 'My Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get logoutButton => 'Logout';

  @override
  String get sendAlertTitle => 'Send Alert';

  @override
  String get alertTitleLabel => 'Alert Title';

  @override
  String get alertTitleHint => 'e.g., Gate Closure Change';

  @override
  String get messageLabel => 'Message';

  @override
  String get messageHint => 'Describe the alert...';

  @override
  String get recipientLabel => 'Recipient';

  @override
  String get recipientHint => 'Select recipient';

  @override
  String get allUsers => 'All Users';

  @override
  String get fansOnly => 'Fans Only';

  @override
  String get securityTeam => 'Security Team';

  @override
  String get emergencyServices => 'Emergency Services';

  @override
  String get sendAlertButton => 'Send Alert';

  @override
  String get alertSentSuccess => 'Alert sent successfully!';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get totalIncidents => 'Total Incidents';

  @override
  String get avgResponse => 'Avg Response';

  @override
  String get peakAttendance => 'Peak Attendance';

  @override
  String get alertsSent => 'Alerts Sent';

  @override
  String get crowdDensityOverTime => 'Crowd Density Over Time';

  @override
  String get crowdDensitySubtitle => 'Average people per m² by hour';

  @override
  String get noDensityData => 'No density data available';

  @override
  String get incidentsByType => 'Incidents by Type';

  @override
  String get totalIncidentsBreakdown => 'Total incidents breakdown';

  @override
  String get noIncidentData => 'No incident data available';

  @override
  String get medicalType => 'Medical';

  @override
  String get securityType => 'Security';

  @override
  String get overcrowdingType => 'Overcrowding';

  @override
  String get otherType => 'Other';

  @override
  String get zoneOccupancyTitle => 'Zone Occupancy Distribution';

  @override
  String get zoneOccupancySubtitle => 'Average density by zone';

  @override
  String get noZoneData => 'No zone data available';

  @override
  String get staffManagement => 'Staff Management';

  @override
  String get allStaffTab => 'All Staff';

  @override
  String get assignmentsTab => 'Assignments';

  @override
  String get zonesTab => 'Zones';

  @override
  String get noStaffFound => 'No staff members found';

  @override
  String get noStaffDesc => 'Security and emergency staff will appear here';

  @override
  String get staffOverview => 'Staff Overview';

  @override
  String get assignedLabel => 'Assigned';

  @override
  String get availableLabel => 'Available';

  @override
  String get assignStaffTitle => 'Assign Staff';

  @override
  String get selectZoneLabel => 'Select Zone';

  @override
  String get chooseZoneHint => 'Choose a zone';

  @override
  String staffCount(int count) {
    return '$count staff';
  }

  @override
  String get assignToZone => 'Assign to Zone';

  @override
  String staffAssignedSuccess(String name, String zone) {
    return '$name assigned to $zone';
  }

  @override
  String get staffAssignmentFailed => 'Failed to assign staff';

  @override
  String get noAssignments => 'No active assignments';

  @override
  String get assignStaffInstructions =>
      'Assign staff to zones from the All Staff tab';

  @override
  String get assignmentRemoved => 'Assignment removed';

  @override
  String get assignmentRemovalFailed => 'Failed to remove assignment';

  @override
  String get reassignButton => 'Reassign';

  @override
  String get assignButton => 'Assign';

  @override
  String get noZonesFound => 'No zones found';

  @override
  String get noZonesDesc => 'Zones will appear once event data is loaded';

  @override
  String get securityDashboard => 'Security Dashboard';

  @override
  String get onDuty => 'On Duty';

  @override
  String get offDuty => 'Off Duty';

  @override
  String get monitorCrowd => 'Monitor Crowd';

  @override
  String get incidentTypeLabel => 'Incident Type';

  @override
  String get selectTypeHint => 'Select type';

  @override
  String get crowdIssue => 'Crowd Issue';

  @override
  String get medicalEmergency => 'Medical Emergency';

  @override
  String get securityThreat => 'Security Threat';

  @override
  String get fireHazard => 'Fire Hazard';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint => 'Enter details about the incident...';

  @override
  String get attachImage => 'Attach Image';

  @override
  String get incidentSentText => 'Incident sent to Security Team.';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get incidentReportedSuccess => 'Incident reported successfully!';

  @override
  String get emergencyDashboard => 'Emergency Dashboard';

  @override
  String get dispatchButton => 'Dispatch';

  @override
  String get evacuateButton => 'Evacuate';

  @override
  String get reportIncidentTitle => 'Report Incident';

  @override
  String get incidentTypeSection => 'Incident Type';

  @override
  String get severityLevelSection => 'Severity Level';

  @override
  String get descriptionSection => 'Description';

  @override
  String get photosSection => 'Photos (Optional)';

  @override
  String get facilityType => 'Facility';

  @override
  String get lowSeverity => 'Low';

  @override
  String get mediumSeverity => 'Medium';

  @override
  String get highSeverity => 'High';

  @override
  String get criticalSeverity => 'Critical';

  @override
  String get describeIncident => 'Describe what happened...';

  @override
  String get addPhotos => 'Add Photos';

  @override
  String photosAdded(int count) {
    return '$count/3 photos added';
  }

  @override
  String get cameraOption => 'Camera';

  @override
  String get galleryOption => 'Gallery';

  @override
  String get imagePickFailed => 'Failed to pick image';

  @override
  String get descriptionRequired => 'Please describe the incident';

  @override
  String get incidentReportSuccess => 'Incident reported successfully';

  @override
  String get incidentReportFailed => 'Failed to report incident';

  @override
  String get communicationHub => 'Communication Hub';

  @override
  String get channelsSection => 'Channels';

  @override
  String get noChannels => 'No channels available';

  @override
  String get selectChannel => 'Select a channel to start messaging';

  @override
  String messageCount(int count) {
    return '$count messages';
  }

  @override
  String get noMessages => 'No messages yet';

  @override
  String get startConversation => 'Start the conversation';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get lastUpdated => 'Last updated: January 2026';

  @override
  String get introductionSection => 'Introduction';

  @override
  String get dataCollectionSection => '1. Data Collection';

  @override
  String get consentSection => '2. Consent & Location Sharing';

  @override
  String get gdprRightsSection => '3. Your Rights (GDPR Compliance)';

  @override
  String get dataRetentionSection => '4. Data Retention';

  @override
  String get securityMeasuresSection => '5. Security Measures';

  @override
  String get thirdPartySection => '6. Third-Party Services';

  @override
  String get contactInfoSection => '7. Contact Information';

  @override
  String get policyChangesSection => '8. Changes to This Policy';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'Network error. Please check your connection.';

  @override
  String get errorInvalidEmail => 'Please enter a valid email address.';

  @override
  String get errorInvalidPassword =>
      'Password must be at least 8 characters with 1 uppercase letter and 1 number.';

  @override
  String get errorLoginFailed => 'Invalid email or password.';

  @override
  String get errorEmptyField => 'This field cannot be empty.';

  @override
  String get errorAccountLocked =>
      'Account temporarily locked due to too many failed attempts. Try again later.';

  @override
  String get errorEmailNotVerified =>
      'Please verify your email before signing in.';

  @override
  String get successLogin => 'Login successful!';

  @override
  String get successRegister =>
      'Registration successful! Please verify your email.';

  @override
  String get successAlertSent => 'Alert sent successfully!';

  @override
  String get successIncidentReported => 'Incident reported successfully!';

  @override
  String get successStatusUpdated => 'Status updated successfully!';

  @override
  String get successEmailVerification =>
      'Verification email sent. Please check your inbox.';

  @override
  String get congestionAlert => 'Congestion Alert';

  @override
  String get safetyAlert => 'Safety Alert';

  @override
  String get emergencyAlert => 'Emergency Alert';

  @override
  String get informationAlert => 'Information';

  @override
  String capacityPercent(int percent) {
    return '$percent% Capacity';
  }

  @override
  String peoplePerSqm(String value) {
    return '$value p/m²';
  }

  @override
  String degreeCelsius(String temp) {
    return '$temp°C';
  }

  @override
  String get totalPopulation => 'Total Population';

  @override
  String get totalCapacity => 'Total Capacity';

  @override
  String get overallOccupancy => 'Overall Occupancy';

  @override
  String get criticalZones => 'Critical Zones';

  @override
  String get highDensityZones => 'High Density Zones';

  @override
  String get safeZonesLabel => 'Safe Zones';

  @override
  String get avgDensityLabel => 'Avg Density';

  @override
  String get zoneMonitoring => 'Zone Monitoring';

  @override
  String get noZoneDataAvailable => 'No zone data available';

  @override
  String get createEvent => 'Create Event';

  @override
  String get searchEvents => 'Search Events';

  @override
  String get managedEvents => 'Managed Events';

  @override
  String get noEventsFound => 'No events found';

  @override
  String get eventActive => 'Active';

  @override
  String get eventPlanned => 'Planned';

  @override
  String get eventCompleted => 'Completed';

  @override
  String get attendanceLabel => 'Attendance';

  @override
  String expectedAttendance(int count) {
    return 'Expected: $count';
  }

  @override
  String get demoBanner => 'Demo Mode';

  @override
  String get quickLogin => 'Quick Login';

  @override
  String get demoCredentialsLabel => 'Demo Accounts';

  @override
  String get tapToLogin => 'Tap any account to login instantly';

  @override
  String passwordValidation(int min) {
    return 'Password must be at least $min characters long.';
  }

  @override
  String passwordMaxLength(int max) {
    return 'Password must be less than $max characters.';
  }

  @override
  String get passwordUppercase =>
      'Password must contain at least one uppercase letter.';

  @override
  String get passwordNumber => 'Password must contain at least one number.';

  @override
  String nameMinLengthValidation(int min) {
    return 'Name must be at least $min characters.';
  }

  @override
  String nameMaxLengthValidation(int max) {
    return 'Name must be less than $max characters.';
  }

  @override
  String get alertResolvedSnack => 'Alert resolved';

  @override
  String get eventCreatedSuccess => 'Event created successfully!';

  @override
  String eventCreatedFailed(String error) {
    return 'Failed to create event: $error';
  }

  @override
  String searchingFor(String value) {
    return 'Searching for \"$value\"...';
  }

  @override
  String get incidentAcknowledged => 'Incident acknowledged';

  @override
  String get teamDispatched => 'Team dispatched';

  @override
  String get statusOnSite => 'Status: On Site';

  @override
  String get incidentResolved => 'Incident resolved';

  @override
  String get failedPickImage => 'Failed to pick image';

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get textMessage => 'Text Message';

  @override
  String get alertMessage => 'Alert';

  @override
  String get incidentUpdate => 'Incident Update';

  @override
  String get seedData => 'Seed Data';

  @override
  String get seedingFailedShort => 'Seeding failed';

  @override
  String get failedDeleteAccount => 'Failed to delete account';

  @override
  String passwordResetSent(String email) {
    return 'Password reset link sent to $email';
  }

  @override
  String get initiateEvacuation => 'Initiate Evacuation?';

  @override
  String get evacuationSentSuccess => 'Evacuation alert sent to all users';

  @override
  String get evacuationFailed => 'Failed to send evacuation alert';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get fillAllFields => 'Please fill in all fields';

  @override
  String get passwordMinChars => 'New password must be at least 8 characters';

  @override
  String get passwordsDoNotMatch => 'New passwords do not match';

  @override
  String get viewDetails => 'View Details';

  @override
  String get deleteButton => 'Delete';

  @override
  String get passwordResetFailed => 'Failed to send reset email';

  @override
  String get yourEmail => 'your email';

  @override
  String get selectChannelToMessage => 'Select a channel to start messaging';

  @override
  String get sendingAsAlert => 'Sending as Alert';

  @override
  String get sendingAsIncidentUpdate => 'Sending as Incident Update';

  @override
  String get channel => 'Channel';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get securityAndEmergencyStaffWillAppear =>
      'Security and emergency staff will appear here';

  @override
  String get failedToAssignStaff => 'Failed to assign staff';

  @override
  String get security => 'Security';

  @override
  String get emergency => 'Emergency';

  @override
  String get noActiveAssignments => 'No active assignments';

  @override
  String get assignStaffToZones =>
      'Assign staff to zones from the All Staff tab';

  @override
  String get failedToRemoveAssignment => 'Failed to remove assignment';

  @override
  String get zonesWillAppearOnceEventDataLoaded =>
      'Zones will appear once event data is loaded';

  @override
  String get safeDensity => 'Safe (<1.5)';

  @override
  String get moderateDensity => 'Moderate';

  @override
  String get highDensity => 'High';

  @override
  String get criticalDensity => 'Critical (>4.5)';

  @override
  String get failedSendEvacuationAlert => 'Failed to send evacuation alert';

  @override
  String get activeEvents => 'Active Events';

  @override
  String get crowdZones => 'Crowd Zones';

  @override
  String get alerts => 'Alerts';

  @override
  String get incidents => 'Incidents';

  @override
  String get currentEventLabel => 'Current Event:';

  @override
  String get liveEventStatus => 'Live';

  @override
  String get upcomingEventStatus => 'Upcoming';

  @override
  String get endedEventStatus => 'Ended';

  @override
  String get organizerDashboard => 'Organizer Dashboard';

  @override
  String get liveEventMap => 'Live Event Map';

  @override
  String get createEventButton => 'Create Event';

  @override
  String get eventTitleLabel => 'Event Name';

  @override
  String get eventTitleHint => 'e.g., FIFA World Cup - Group Stage';

  @override
  String get eventDescriptionLabel => 'Description';

  @override
  String get eventDescriptionHint => 'Describe event...';

  @override
  String get searchLabel => 'Search';

  @override
  String get searchHint => 'Search events, zones, alerts...';

  @override
  String get quickAccess => 'Quick Access';

  @override
  String get incidentSentToSecurity => 'Incident sent to Security Team.';

  @override
  String get viewAlertsButton => 'View Alerts';

  @override
  String get teamUpdatesButton => 'Team Updates';

  @override
  String get activeAlertsTitle => 'Active Alerts';

  @override
  String get noActiveAlerts => 'No active alerts';

  @override
  String get criticalDensityStatus => 'Critical';

  @override
  String get highDensityStatus => 'High Density';

  @override
  String get normalDensityStatus => 'Normal';

  @override
  String get capacityLabel => '% Capacity';

  @override
  String currentAvgDensityValue(Object value) {
    return '$value Avg. Density';
  }

  @override
  String get aboveRecommended => 'Above Recommended';

  @override
  String get reportButtonShort => 'Report...';

  @override
  String get viewAlertsShort => 'View A...';

  @override
  String get emergencyTitle => 'Emergency';

  @override
  String get evacuationWarning =>
      'This will trigger an evacuation alert for all attendees and staff in venue. This action cannot be undone.';

  @override
  String get evacuationOrderMessage =>
      'EVACUATION ORDER: All attendees and staff must evacuate venue immediately. Follow emergency exit routes.';

  @override
  String minutesAgoShort(Object minutes) {
    return '${minutes}m ago';
  }

  @override
  String get allIncidentsTitle => 'All Incidents';

  @override
  String get noActiveIncidents => 'No Active Incidents';

  @override
  String get allEmergenciesResolved => 'All emergencies have been resolved';
}
