import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Mundial'**
  String get appName;

  /// No description provided for @appNameManager.
  ///
  /// In en, this message translates to:
  /// **'MANAGER'**
  String get appNameManager;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Crowd Management for FIFA World Cup 2026'**
  String get appTagline;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your account details.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @orRegisterWith.
  ///
  /// In en, this message translates to:
  /// **'or Register With'**
  String get orRegisterWith;

  /// No description provided for @googleSignInComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in coming soon'**
  String get googleSignInComingSoon;

  /// No description provided for @facebookSignInComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Facebook sign-in coming soon'**
  String get facebookSignInComingSoon;

  /// No description provided for @appleSignInComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in coming soon'**
  String get appleSignInComingSoon;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @registerLink.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerLink;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordDesc;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @sendLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get sendLinkButton;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get createAccountTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get nameHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPasswordHint;

  /// No description provided for @selectRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Your Role'**
  String get selectRoleLabel;

  /// No description provided for @selectRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get selectRoleHint;

  /// No description provided for @roleFan.
  ///
  /// In en, this message translates to:
  /// **'Fan'**
  String get roleFan;

  /// No description provided for @roleOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Event Organizer'**
  String get roleOrganizer;

  /// No description provided for @roleSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security Team'**
  String get roleSecurity;

  /// No description provided for @roleEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency Services'**
  String get roleEmergency;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLink;

  /// No description provided for @passwordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsMismatch;

  /// No description provided for @pleaseSelectRole.
  ///
  /// In en, this message translates to:
  /// **'Please select a role'**
  String get pleaseSelectRole;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccess;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameRequired;

  /// No description provided for @nameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLength;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @roleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a role'**
  String get roleRequired;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// No description provided for @emailSentTo.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification email to:'**
  String get emailSentTo;

  /// No description provided for @verifyEmailInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox and click the verification link to activate your account. If you don\'t see the email, check your spam or junk folder.'**
  String get verifyEmailInstructions;

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Verified, Continue'**
  String get verifyAndContinue;

  /// No description provided for @checkingStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checkingStatus;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendEmail;

  /// No description provided for @resendEmailCooldown.
  ///
  /// In en, this message translates to:
  /// **'Resend Email ({seconds} s)'**
  String resendEmailCooldown(int seconds);

  /// No description provided for @canResendIn.
  ///
  /// In en, this message translates to:
  /// **'You can resend in {seconds} seconds'**
  String canResendIn(int seconds);

  /// No description provided for @verifyEmailHelp.
  ///
  /// In en, this message translates to:
  /// **'Having trouble? Make sure to check your spam folder. The email may take a few minutes to arrive.'**
  String get verifyEmailHelp;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet. Please check your inbox.'**
  String get emailNotVerified;

  /// No description provided for @verificationCheckError.
  ///
  /// In en, this message translates to:
  /// **'Error checking verification status'**
  String get verificationCheckError;

  /// No description provided for @emailSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent!'**
  String get emailSentSuccess;

  /// No description provided for @emailSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification email. Please try again.'**
  String get emailSendFailed;

  /// No description provided for @selectYourRole.
  ///
  /// In en, this message translates to:
  /// **'Select Your Role'**
  String get selectYourRole;

  /// No description provided for @chooseYourRole.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Role'**
  String get chooseYourRole;

  /// No description provided for @selectRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the role that best describes your access level'**
  String get selectRoleDescription;

  /// No description provided for @roleFanDesc.
  ///
  /// In en, this message translates to:
  /// **'View venue maps, receive safety alerts, and navigate efficiently'**
  String get roleFanDesc;

  /// No description provided for @roleOrganizerDesc.
  ///
  /// In en, this message translates to:
  /// **'Monitor crowds, send alerts, manage staff, and view analytics'**
  String get roleOrganizerDesc;

  /// No description provided for @roleSecurityDesc.
  ///
  /// In en, this message translates to:
  /// **'Report incidents, monitor zones, and coordinate responses'**
  String get roleSecurityDesc;

  /// No description provided for @roleEmergencyDesc.
  ///
  /// In en, this message translates to:
  /// **'View incident locations, update response status, and communicate'**
  String get roleEmergencyDesc;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeUser(String name);

  /// No description provided for @currentEvent.
  ///
  /// In en, this message translates to:
  /// **'Current Event:'**
  String get currentEvent;

  /// No description provided for @noActiveEvent.
  ///
  /// In en, this message translates to:
  /// **'No active event'**
  String get noActiveEvent;

  /// No description provided for @activeAlerts.
  ///
  /// In en, this message translates to:
  /// **'Active Alerts'**
  String get activeAlerts;

  /// No description provided for @viewAllAlerts.
  ///
  /// In en, this message translates to:
  /// **'View All Alerts'**
  String get viewAllAlerts;

  /// No description provided for @viewMap.
  ///
  /// In en, this message translates to:
  /// **'View Map'**
  String get viewMap;

  /// No description provided for @viewAlerts.
  ///
  /// In en, this message translates to:
  /// **'View Alerts'**
  String get viewAlerts;

  /// No description provided for @reportIncident.
  ///
  /// In en, this message translates to:
  /// **'Report Incident'**
  String get reportIncident;

  /// No description provided for @locationSharingOn.
  ///
  /// In en, this message translates to:
  /// **'Location Sharing: ON'**
  String get locationSharingOn;

  /// No description provided for @shareMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Share My Location'**
  String get shareMyLocation;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @mapTab.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTab;

  /// No description provided for @alertsTab.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get viewOnMap;

  /// No description provided for @eventMap.
  ///
  /// In en, this message translates to:
  /// **'Event Map'**
  String get eventMap;

  /// No description provided for @liveCrowdMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Live Crowd Monitoring'**
  String get liveCrowdMonitoring;

  /// No description provided for @averageDensity.
  ///
  /// In en, this message translates to:
  /// **'Average Density'**
  String get averageDensity;

  /// No description provided for @currentAvgDensity.
  ///
  /// In en, this message translates to:
  /// **'Current Avg. Density'**
  String currentAvgDensity(int percent);

  /// No description provided for @activeCriticalAlerts.
  ///
  /// In en, this message translates to:
  /// **'Active Critical Alerts: {count}'**
  String activeCriticalAlerts(int count);

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @densitySafe.
  ///
  /// In en, this message translates to:
  /// **'Safe (<1.5)'**
  String get densitySafe;

  /// No description provided for @densityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get densityModerate;

  /// No description provided for @densityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get densityHigh;

  /// No description provided for @densityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical (>4.5)'**
  String get densityCritical;

  /// No description provided for @populationLabel.
  ///
  /// In en, this message translates to:
  /// **'Population'**
  String get populationLabel;

  /// No description provided for @occupancyLabel.
  ///
  /// In en, this message translates to:
  /// **'Occupancy'**
  String get occupancyLabel;

  /// No description provided for @densityLabel.
  ///
  /// In en, this message translates to:
  /// **'Density'**
  String get densityLabel;

  /// No description provided for @temperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperatureLabel;

  /// No description provided for @weatherLabel.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weatherLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @statusSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get statusSafe;

  /// No description provided for @statusModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get statusModerate;

  /// No description provided for @statusHighDensity.
  ///
  /// In en, this message translates to:
  /// **'High Density'**
  String get statusHighDensity;

  /// No description provided for @statusCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get statusCritical;

  /// No description provided for @peopleAlerts.
  ///
  /// In en, this message translates to:
  /// **'People Alerts'**
  String get peopleAlerts;

  /// No description provided for @noAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'No alerts at the moment'**
  String get noAlertsTitle;

  /// No description provided for @noAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be notified of any safety updates'**
  String get noAlertsSubtitle;

  /// No description provided for @activeFilter.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeFilter;

  /// No description provided for @resolvedFilter.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolvedFilter;

  /// No description provided for @criticalLabel.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get criticalLabel;

  /// No description provided for @highLabel.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get highLabel;

  /// No description provided for @moderateLabel.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderateLabel;

  /// No description provided for @infoLabel.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get infoLabel;

  /// No description provided for @resolvedLabel.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolvedLabel;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// No description provided for @severityLabel.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severityLabel;

  /// No description provided for @affectedZone.
  ///
  /// In en, this message translates to:
  /// **'Affected Zone'**
  String get affectedZone;

  /// No description provided for @allZones.
  ///
  /// In en, this message translates to:
  /// **'All zones'**
  String get allZones;

  /// No description provided for @acknowledgeButton.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get acknowledgeButton;

  /// No description provided for @notifyEmergency.
  ///
  /// In en, this message translates to:
  /// **'Notify Emergency'**
  String get notifyEmergency;

  /// No description provided for @markResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark Resolved'**
  String get markResolved;

  /// No description provided for @alertAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'Alert acknowledged and dismissed'**
  String get alertAcknowledged;

  /// No description provided for @alertAcknowledgeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to acknowledge alert'**
  String get alertAcknowledgeFailed;

  /// No description provided for @emergencyNotified.
  ///
  /// In en, this message translates to:
  /// **'Emergency team has been notified'**
  String get emergencyNotified;

  /// No description provided for @emergencyNotifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to notify emergency team'**
  String get emergencyNotifyFailed;

  /// No description provided for @alertResolved.
  ///
  /// In en, this message translates to:
  /// **'Alert marked as resolved'**
  String get alertResolved;

  /// No description provided for @alertResolveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to resolve alert'**
  String get alertResolveFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @displayPreferences.
  ///
  /// In en, this message translates to:
  /// **'Display Preferences'**
  String get displayPreferences;

  /// No description provided for @notificationsAlerts.
  ///
  /// In en, this message translates to:
  /// **'Notifications & Alerts'**
  String get notificationsAlerts;

  /// No description provided for @languageLocalization.
  ///
  /// In en, this message translates to:
  /// **'Language & Localization'**
  String get languageLocalization;

  /// No description provided for @privacyAccount.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Account'**
  String get privacyAccount;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// No description provided for @restoreDefaults.
  ///
  /// In en, this message translates to:
  /// **'Restore Defaults'**
  String get restoreDefaults;

  /// No description provided for @seedDemoData.
  ///
  /// In en, this message translates to:
  /// **'Seed Demo Data'**
  String get seedDemoData;

  /// No description provided for @securedByFirebase.
  ///
  /// In en, this message translates to:
  /// **'Secured by Firebase'**
  String get securedByFirebase;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme throughout the app'**
  String get darkModeSubtitle;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// No description provided for @textSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get textSizeSmall;

  /// No description provided for @textSizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get textSizeMedium;

  /// No description provided for @textSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textSizeLarge;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications on your device'**
  String get pushNotificationsSubtitle;

  /// No description provided for @soundLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundLabel;

  /// No description provided for @soundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play sound for new alerts'**
  String get soundSubtitle;

  /// No description provided for @crowdAlerts.
  ///
  /// In en, this message translates to:
  /// **'Crowd Alerts'**
  String get crowdAlerts;

  /// No description provided for @crowdAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified about crowd density changes'**
  String get crowdAlertsSubtitle;

  /// No description provided for @emergencyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Alerts'**
  String get emergencyAlerts;

  /// No description provided for @emergencyAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive critical emergency notifications'**
  String get emergencyAlertsSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @locationSharing.
  ///
  /// In en, this message translates to:
  /// **'Location Sharing'**
  String get locationSharing;

  /// No description provided for @locationSharingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your location for crowd tracking'**
  String get locationSharingSubtitle;

  /// No description provided for @analyticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsLabel;

  /// No description provided for @analyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help improve the app with usage data'**
  String get analyticsSubtitle;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSaved;

  /// No description provided for @settingsRestored.
  ///
  /// In en, this message translates to:
  /// **'Settings restored to defaults'**
  String get settingsRestored;

  /// No description provided for @seedDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Seed Demo Data'**
  String get seedDataTitle;

  /// No description provided for @seedDataDesc.
  ///
  /// In en, this message translates to:
  /// **'This will clear existing data and load fresh demo data (events, zones, crowd density, incidents, alerts, etc.).\n\nYou will be signed out and need to log back in.'**
  String get seedDataDesc;

  /// No description provided for @seedDataButton.
  ///
  /// In en, this message translates to:
  /// **'Seed Data'**
  String get seedDataButton;

  /// No description provided for @seedingFailed.
  ///
  /// In en, this message translates to:
  /// **'Seeding failed: {error}'**
  String seedingFailed(String error);

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @sendAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Alert'**
  String get sendAlertTitle;

  /// No description provided for @alertTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Alert Title'**
  String get alertTitleLabel;

  /// No description provided for @alertTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Gate Closure Change'**
  String get alertTitleHint;

  /// No description provided for @messageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageLabel;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the alert...'**
  String get messageHint;

  /// No description provided for @recipientLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get recipientLabel;

  /// No description provided for @recipientHint.
  ///
  /// In en, this message translates to:
  /// **'Select recipient'**
  String get recipientHint;

  /// No description provided for @allUsers.
  ///
  /// In en, this message translates to:
  /// **'All Users'**
  String get allUsers;

  /// No description provided for @fansOnly.
  ///
  /// In en, this message translates to:
  /// **'Fans Only'**
  String get fansOnly;

  /// No description provided for @securityTeam.
  ///
  /// In en, this message translates to:
  /// **'Security Team'**
  String get securityTeam;

  /// No description provided for @emergencyServices.
  ///
  /// In en, this message translates to:
  /// **'Emergency Services'**
  String get emergencyServices;

  /// No description provided for @sendAlertButton.
  ///
  /// In en, this message translates to:
  /// **'Send Alert'**
  String get sendAlertButton;

  /// No description provided for @alertSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Alert sent successfully!'**
  String get alertSentSuccess;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @totalIncidents.
  ///
  /// In en, this message translates to:
  /// **'Total Incidents'**
  String get totalIncidents;

  /// No description provided for @avgResponse.
  ///
  /// In en, this message translates to:
  /// **'Avg Response'**
  String get avgResponse;

  /// No description provided for @peakAttendance.
  ///
  /// In en, this message translates to:
  /// **'Peak Attendance'**
  String get peakAttendance;

  /// No description provided for @alertsSent.
  ///
  /// In en, this message translates to:
  /// **'Alerts Sent'**
  String get alertsSent;

  /// No description provided for @crowdDensityOverTime.
  ///
  /// In en, this message translates to:
  /// **'Crowd Density Over Time'**
  String get crowdDensityOverTime;

  /// No description provided for @crowdDensitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Average people per m² by hour'**
  String get crowdDensitySubtitle;

  /// No description provided for @noDensityData.
  ///
  /// In en, this message translates to:
  /// **'No density data available'**
  String get noDensityData;

  /// No description provided for @incidentsByType.
  ///
  /// In en, this message translates to:
  /// **'Incidents by Type'**
  String get incidentsByType;

  /// No description provided for @totalIncidentsBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Total incidents breakdown'**
  String get totalIncidentsBreakdown;

  /// No description provided for @noIncidentData.
  ///
  /// In en, this message translates to:
  /// **'No incident data available'**
  String get noIncidentData;

  /// No description provided for @medicalType.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get medicalType;

  /// No description provided for @securityType.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityType;

  /// No description provided for @overcrowdingType.
  ///
  /// In en, this message translates to:
  /// **'Overcrowding'**
  String get overcrowdingType;

  /// No description provided for @otherType.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherType;

  /// No description provided for @zoneOccupancyTitle.
  ///
  /// In en, this message translates to:
  /// **'Zone Occupancy Distribution'**
  String get zoneOccupancyTitle;

  /// No description provided for @zoneOccupancySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Average density by zone'**
  String get zoneOccupancySubtitle;

  /// No description provided for @noZoneData.
  ///
  /// In en, this message translates to:
  /// **'No zone data available'**
  String get noZoneData;

  /// No description provided for @staffManagement.
  ///
  /// In en, this message translates to:
  /// **'Staff Management'**
  String get staffManagement;

  /// No description provided for @allStaffTab.
  ///
  /// In en, this message translates to:
  /// **'All Staff'**
  String get allStaffTab;

  /// No description provided for @assignmentsTab.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get assignmentsTab;

  /// No description provided for @zonesTab.
  ///
  /// In en, this message translates to:
  /// **'Zones'**
  String get zonesTab;

  /// No description provided for @noStaffFound.
  ///
  /// In en, this message translates to:
  /// **'No staff members found'**
  String get noStaffFound;

  /// No description provided for @noStaffDesc.
  ///
  /// In en, this message translates to:
  /// **'Security and emergency staff will appear here'**
  String get noStaffDesc;

  /// No description provided for @staffOverview.
  ///
  /// In en, this message translates to:
  /// **'Staff Overview'**
  String get staffOverview;

  /// No description provided for @assignedLabel.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assignedLabel;

  /// No description provided for @availableLabel.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableLabel;

  /// No description provided for @assignStaffTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign Staff'**
  String get assignStaffTitle;

  /// No description provided for @selectZoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Zone'**
  String get selectZoneLabel;

  /// No description provided for @chooseZoneHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a zone'**
  String get chooseZoneHint;

  /// No description provided for @staffCount.
  ///
  /// In en, this message translates to:
  /// **'{count} staff'**
  String staffCount(int count);

  /// No description provided for @assignToZone.
  ///
  /// In en, this message translates to:
  /// **'Assign to Zone'**
  String get assignToZone;

  /// No description provided for @staffAssignedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} assigned to {zone}'**
  String staffAssignedSuccess(String name, String zone);

  /// No description provided for @staffAssignmentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to assign staff'**
  String get staffAssignmentFailed;

  /// No description provided for @noAssignments.
  ///
  /// In en, this message translates to:
  /// **'No active assignments'**
  String get noAssignments;

  /// No description provided for @assignStaffInstructions.
  ///
  /// In en, this message translates to:
  /// **'Assign staff to zones from the All Staff tab'**
  String get assignStaffInstructions;

  /// No description provided for @assignmentRemoved.
  ///
  /// In en, this message translates to:
  /// **'Assignment removed'**
  String get assignmentRemoved;

  /// No description provided for @assignmentRemovalFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove assignment'**
  String get assignmentRemovalFailed;

  /// No description provided for @reassignButton.
  ///
  /// In en, this message translates to:
  /// **'Reassign'**
  String get reassignButton;

  /// No description provided for @assignButton.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assignButton;

  /// No description provided for @noZonesFound.
  ///
  /// In en, this message translates to:
  /// **'No zones found'**
  String get noZonesFound;

  /// No description provided for @noZonesDesc.
  ///
  /// In en, this message translates to:
  /// **'Zones will appear once event data is loaded'**
  String get noZonesDesc;

  /// No description provided for @securityDashboard.
  ///
  /// In en, this message translates to:
  /// **'Security Dashboard'**
  String get securityDashboard;

  /// No description provided for @onDuty.
  ///
  /// In en, this message translates to:
  /// **'On Duty'**
  String get onDuty;

  /// No description provided for @offDuty.
  ///
  /// In en, this message translates to:
  /// **'Off Duty'**
  String get offDuty;

  /// No description provided for @monitorCrowd.
  ///
  /// In en, this message translates to:
  /// **'Monitor Crowd'**
  String get monitorCrowd;

  /// No description provided for @incidentTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Incident Type'**
  String get incidentTypeLabel;

  /// No description provided for @selectTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select type'**
  String get selectTypeHint;

  /// No description provided for @crowdIssue.
  ///
  /// In en, this message translates to:
  /// **'Crowd Issue'**
  String get crowdIssue;

  /// No description provided for @medicalEmergency.
  ///
  /// In en, this message translates to:
  /// **'Medical Emergency'**
  String get medicalEmergency;

  /// No description provided for @securityThreat.
  ///
  /// In en, this message translates to:
  /// **'Security Threat'**
  String get securityThreat;

  /// No description provided for @fireHazard.
  ///
  /// In en, this message translates to:
  /// **'Fire Hazard'**
  String get fireHazard;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter details about the incident...'**
  String get descriptionHint;

  /// No description provided for @attachImage.
  ///
  /// In en, this message translates to:
  /// **'Attach Image'**
  String get attachImage;

  /// No description provided for @incidentSentText.
  ///
  /// In en, this message translates to:
  /// **'Incident sent to Security Team.'**
  String get incidentSentText;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @incidentReportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Incident reported successfully!'**
  String get incidentReportedSuccess;

  /// No description provided for @emergencyDashboard.
  ///
  /// In en, this message translates to:
  /// **'Emergency Dashboard'**
  String get emergencyDashboard;

  /// No description provided for @dispatchButton.
  ///
  /// In en, this message translates to:
  /// **'Dispatch'**
  String get dispatchButton;

  /// No description provided for @evacuateButton.
  ///
  /// In en, this message translates to:
  /// **'Evacuate'**
  String get evacuateButton;

  /// No description provided for @reportIncidentTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Incident'**
  String get reportIncidentTitle;

  /// No description provided for @incidentTypeSection.
  ///
  /// In en, this message translates to:
  /// **'Incident Type'**
  String get incidentTypeSection;

  /// No description provided for @severityLevelSection.
  ///
  /// In en, this message translates to:
  /// **'Severity Level'**
  String get severityLevelSection;

  /// No description provided for @descriptionSection.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionSection;

  /// No description provided for @photosSection.
  ///
  /// In en, this message translates to:
  /// **'Photos (Optional)'**
  String get photosSection;

  /// No description provided for @facilityType.
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get facilityType;

  /// No description provided for @lowSeverity.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get lowSeverity;

  /// No description provided for @mediumSeverity.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mediumSeverity;

  /// No description provided for @highSeverity.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get highSeverity;

  /// No description provided for @criticalSeverity.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get criticalSeverity;

  /// No description provided for @describeIncident.
  ///
  /// In en, this message translates to:
  /// **'Describe what happened...'**
  String get describeIncident;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// No description provided for @photosAdded.
  ///
  /// In en, this message translates to:
  /// **'{count}/3 photos added'**
  String photosAdded(int count);

  /// No description provided for @cameraOption.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraOption;

  /// No description provided for @galleryOption.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryOption;

  /// No description provided for @imagePickFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get imagePickFailed;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please describe the incident'**
  String get descriptionRequired;

  /// No description provided for @incidentReportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Incident reported successfully'**
  String get incidentReportSuccess;

  /// No description provided for @incidentReportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to report incident'**
  String get incidentReportFailed;

  /// No description provided for @communicationHub.
  ///
  /// In en, this message translates to:
  /// **'Communication Hub'**
  String get communicationHub;

  /// No description provided for @channelsSection.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channelsSection;

  /// No description provided for @noChannels.
  ///
  /// In en, this message translates to:
  /// **'No channels available'**
  String get noChannels;

  /// No description provided for @selectChannel.
  ///
  /// In en, this message translates to:
  /// **'Select a channel to start messaging'**
  String get selectChannel;

  /// No description provided for @messageCount.
  ///
  /// In en, this message translates to:
  /// **'{count} messages'**
  String messageCount(int count);

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation'**
  String get startConversation;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: January 2026'**
  String get lastUpdated;

  /// No description provided for @introductionSection.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get introductionSection;

  /// No description provided for @dataCollectionSection.
  ///
  /// In en, this message translates to:
  /// **'1. Data Collection'**
  String get dataCollectionSection;

  /// No description provided for @consentSection.
  ///
  /// In en, this message translates to:
  /// **'2. Consent & Location Sharing'**
  String get consentSection;

  /// No description provided for @gdprRightsSection.
  ///
  /// In en, this message translates to:
  /// **'3. Your Rights (GDPR Compliance)'**
  String get gdprRightsSection;

  /// No description provided for @dataRetentionSection.
  ///
  /// In en, this message translates to:
  /// **'4. Data Retention'**
  String get dataRetentionSection;

  /// No description provided for @securityMeasuresSection.
  ///
  /// In en, this message translates to:
  /// **'5. Security Measures'**
  String get securityMeasuresSection;

  /// No description provided for @thirdPartySection.
  ///
  /// In en, this message translates to:
  /// **'6. Third-Party Services'**
  String get thirdPartySection;

  /// No description provided for @contactInfoSection.
  ///
  /// In en, this message translates to:
  /// **'7. Contact Information'**
  String get contactInfoSection;

  /// No description provided for @policyChangesSection.
  ///
  /// In en, this message translates to:
  /// **'8. Changes to This Policy'**
  String get policyChangesSection;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get errorInvalidEmail;

  /// No description provided for @errorInvalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters with 1 uppercase letter and 1 number.'**
  String get errorInvalidPassword;

  /// No description provided for @errorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get errorLoginFailed;

  /// No description provided for @errorEmptyField.
  ///
  /// In en, this message translates to:
  /// **'This field cannot be empty.'**
  String get errorEmptyField;

  /// No description provided for @errorAccountLocked.
  ///
  /// In en, this message translates to:
  /// **'Account temporarily locked due to too many failed attempts. Try again later.'**
  String get errorAccountLocked;

  /// No description provided for @errorEmailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email before signing in.'**
  String get errorEmailNotVerified;

  /// No description provided for @successLogin.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get successLogin;

  /// No description provided for @successRegister.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please verify your email.'**
  String get successRegister;

  /// No description provided for @successAlertSent.
  ///
  /// In en, this message translates to:
  /// **'Alert sent successfully!'**
  String get successAlertSent;

  /// No description provided for @successIncidentReported.
  ///
  /// In en, this message translates to:
  /// **'Incident reported successfully!'**
  String get successIncidentReported;

  /// No description provided for @successStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Status updated successfully!'**
  String get successStatusUpdated;

  /// No description provided for @successEmailVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent. Please check your inbox.'**
  String get successEmailVerification;

  /// No description provided for @congestionAlert.
  ///
  /// In en, this message translates to:
  /// **'Congestion Alert'**
  String get congestionAlert;

  /// No description provided for @safetyAlert.
  ///
  /// In en, this message translates to:
  /// **'Safety Alert'**
  String get safetyAlert;

  /// No description provided for @emergencyAlert.
  ///
  /// In en, this message translates to:
  /// **'Emergency Alert'**
  String get emergencyAlert;

  /// No description provided for @informationAlert.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get informationAlert;

  /// No description provided for @capacityPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Capacity'**
  String capacityPercent(int percent);

  /// No description provided for @peoplePerSqm.
  ///
  /// In en, this message translates to:
  /// **'{value} p/m²'**
  String peoplePerSqm(String value);

  /// No description provided for @degreeCelsius.
  ///
  /// In en, this message translates to:
  /// **'{temp}°C'**
  String degreeCelsius(String temp);

  /// No description provided for @totalPopulation.
  ///
  /// In en, this message translates to:
  /// **'Total Population'**
  String get totalPopulation;

  /// No description provided for @totalCapacity.
  ///
  /// In en, this message translates to:
  /// **'Total Capacity'**
  String get totalCapacity;

  /// No description provided for @overallOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Overall Occupancy'**
  String get overallOccupancy;

  /// No description provided for @criticalZones.
  ///
  /// In en, this message translates to:
  /// **'Critical Zones'**
  String get criticalZones;

  /// No description provided for @highDensityZones.
  ///
  /// In en, this message translates to:
  /// **'High Density Zones'**
  String get highDensityZones;

  /// No description provided for @safeZonesLabel.
  ///
  /// In en, this message translates to:
  /// **'Safe Zones'**
  String get safeZonesLabel;

  /// No description provided for @avgDensityLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg Density'**
  String get avgDensityLabel;

  /// No description provided for @zoneMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Zone Monitoring'**
  String get zoneMonitoring;

  /// No description provided for @noZoneDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No zone data available'**
  String get noZoneDataAvailable;

  /// No description provided for @createEvent.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEvent;

  /// No description provided for @searchEvents.
  ///
  /// In en, this message translates to:
  /// **'Search Events'**
  String get searchEvents;

  /// No description provided for @managedEvents.
  ///
  /// In en, this message translates to:
  /// **'Managed Events'**
  String get managedEvents;

  /// No description provided for @noEventsFound.
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get noEventsFound;

  /// No description provided for @eventActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get eventActive;

  /// No description provided for @eventPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get eventPlanned;

  /// No description provided for @eventCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get eventCompleted;

  /// No description provided for @attendanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendanceLabel;

  /// No description provided for @expectedAttendance.
  ///
  /// In en, this message translates to:
  /// **'Expected: {count}'**
  String expectedAttendance(int count);

  /// No description provided for @demoBanner.
  ///
  /// In en, this message translates to:
  /// **'Demo Mode'**
  String get demoBanner;

  /// No description provided for @quickLogin.
  ///
  /// In en, this message translates to:
  /// **'Quick Login'**
  String get quickLogin;

  /// No description provided for @demoCredentialsLabel.
  ///
  /// In en, this message translates to:
  /// **'Demo Accounts'**
  String get demoCredentialsLabel;

  /// No description provided for @tapToLogin.
  ///
  /// In en, this message translates to:
  /// **'Tap any account to login instantly'**
  String get tapToLogin;

  /// No description provided for @passwordValidation.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {min} characters long.'**
  String passwordValidation(int min);

  /// No description provided for @passwordMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be less than {max} characters.'**
  String passwordMaxLength(int max);

  /// No description provided for @passwordUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter.'**
  String get passwordUppercase;

  /// No description provided for @passwordNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number.'**
  String get passwordNumber;

  /// No description provided for @nameMinLengthValidation.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least {min} characters.'**
  String nameMinLengthValidation(int min);

  /// No description provided for @nameMaxLengthValidation.
  ///
  /// In en, this message translates to:
  /// **'Name must be less than {max} characters.'**
  String nameMaxLengthValidation(int max);

  /// No description provided for @alertResolvedSnack.
  ///
  /// In en, this message translates to:
  /// **'Alert resolved'**
  String get alertResolvedSnack;

  /// No description provided for @eventCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event created successfully!'**
  String get eventCreatedSuccess;

  /// No description provided for @eventCreatedFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create event: {error}'**
  String eventCreatedFailed(String error);

  /// No description provided for @searchingFor.
  ///
  /// In en, this message translates to:
  /// **'Searching for \"{value}\"...'**
  String searchingFor(String value);

  /// No description provided for @incidentAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'Incident acknowledged'**
  String get incidentAcknowledged;

  /// No description provided for @teamDispatched.
  ///
  /// In en, this message translates to:
  /// **'Team dispatched'**
  String get teamDispatched;

  /// No description provided for @statusOnSite.
  ///
  /// In en, this message translates to:
  /// **'Status: On Site'**
  String get statusOnSite;

  /// No description provided for @incidentResolved.
  ///
  /// In en, this message translates to:
  /// **'Incident resolved'**
  String get incidentResolved;

  /// No description provided for @failedPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get failedPickImage;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetails(String error);

  /// No description provided for @textMessage.
  ///
  /// In en, this message translates to:
  /// **'Text Message'**
  String get textMessage;

  /// No description provided for @alertMessage.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alertMessage;

  /// No description provided for @incidentUpdate.
  ///
  /// In en, this message translates to:
  /// **'Incident Update'**
  String get incidentUpdate;

  /// No description provided for @seedData.
  ///
  /// In en, this message translates to:
  /// **'Seed Data'**
  String get seedData;

  /// No description provided for @seedingFailedShort.
  ///
  /// In en, this message translates to:
  /// **'Seeding failed'**
  String get seedingFailedShort;

  /// No description provided for @failedDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account'**
  String get failedDeleteAccount;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to {email}'**
  String passwordResetSent(String email);

  /// No description provided for @initiateEvacuation.
  ///
  /// In en, this message translates to:
  /// **'Initiate Evacuation?'**
  String get initiateEvacuation;

  /// No description provided for @evacuationSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Evacuation alert sent to all users'**
  String get evacuationSentSuccess;

  /// No description provided for @evacuationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send evacuation alert'**
  String get evacuationFailed;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFields;

  /// No description provided for @passwordMinChars.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 8 characters'**
  String get passwordMinChars;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @passwordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email'**
  String get passwordResetFailed;

  /// No description provided for @yourEmail.
  ///
  /// In en, this message translates to:
  /// **'your email'**
  String get yourEmail;

  /// No description provided for @selectChannelToMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a channel to start messaging'**
  String get selectChannelToMessage;

  /// No description provided for @sendingAsAlert.
  ///
  /// In en, this message translates to:
  /// **'Sending as Alert'**
  String get sendingAsAlert;

  /// No description provided for @sendingAsIncidentUpdate.
  ///
  /// In en, this message translates to:
  /// **'Sending as Incident Update'**
  String get sendingAsIncidentUpdate;

  /// No description provided for @channel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get channel;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @securityAndEmergencyStaffWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Security and emergency staff will appear here'**
  String get securityAndEmergencyStaffWillAppear;

  /// No description provided for @failedToAssignStaff.
  ///
  /// In en, this message translates to:
  /// **'Failed to assign staff'**
  String get failedToAssignStaff;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @noActiveAssignments.
  ///
  /// In en, this message translates to:
  /// **'No active assignments'**
  String get noActiveAssignments;

  /// No description provided for @assignStaffToZones.
  ///
  /// In en, this message translates to:
  /// **'Assign staff to zones from the All Staff tab'**
  String get assignStaffToZones;

  /// No description provided for @failedToRemoveAssignment.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove assignment'**
  String get failedToRemoveAssignment;

  /// No description provided for @zonesWillAppearOnceEventDataLoaded.
  ///
  /// In en, this message translates to:
  /// **'Zones will appear once event data is loaded'**
  String get zonesWillAppearOnceEventDataLoaded;

  /// No description provided for @safeDensity.
  ///
  /// In en, this message translates to:
  /// **'Safe (<1.5)'**
  String get safeDensity;

  /// No description provided for @moderateDensity.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderateDensity;

  /// No description provided for @highDensity.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get highDensity;

  /// No description provided for @criticalDensity.
  ///
  /// In en, this message translates to:
  /// **'Critical (>4.5)'**
  String get criticalDensity;

  /// No description provided for @failedSendEvacuationAlert.
  ///
  /// In en, this message translates to:
  /// **'Failed to send evacuation alert'**
  String get failedSendEvacuationAlert;

  /// No description provided for @activeEvents.
  ///
  /// In en, this message translates to:
  /// **'Active Events'**
  String get activeEvents;

  /// No description provided for @crowdZones.
  ///
  /// In en, this message translates to:
  /// **'Crowd Zones'**
  String get crowdZones;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @incidents.
  ///
  /// In en, this message translates to:
  /// **'Incidents'**
  String get incidents;

  /// No description provided for @currentEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Event:'**
  String get currentEventLabel;

  /// No description provided for @liveEventStatus.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveEventStatus;

  /// No description provided for @upcomingEventStatus.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingEventStatus;

  /// No description provided for @endedEventStatus.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get endedEventStatus;

  /// No description provided for @organizerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Organizer Dashboard'**
  String get organizerDashboard;

  /// No description provided for @liveEventMap.
  ///
  /// In en, this message translates to:
  /// **'Live Event Map'**
  String get liveEventMap;

  /// No description provided for @createEventButton.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEventButton;

  /// No description provided for @eventTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Event Name'**
  String get eventTitleLabel;

  /// No description provided for @eventTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., FIFA World Cup - Group Stage'**
  String get eventTitleHint;

  /// No description provided for @eventDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get eventDescriptionLabel;

  /// No description provided for @eventDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe event...'**
  String get eventDescriptionHint;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search events, zones, alerts...'**
  String get searchHint;

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccess;

  /// No description provided for @incidentSentToSecurity.
  ///
  /// In en, this message translates to:
  /// **'Incident sent to Security Team.'**
  String get incidentSentToSecurity;

  /// No description provided for @viewAlertsButton.
  ///
  /// In en, this message translates to:
  /// **'View Alerts'**
  String get viewAlertsButton;

  /// No description provided for @teamUpdatesButton.
  ///
  /// In en, this message translates to:
  /// **'Team Updates'**
  String get teamUpdatesButton;

  /// No description provided for @activeAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Alerts'**
  String get activeAlertsTitle;

  /// No description provided for @noActiveAlerts.
  ///
  /// In en, this message translates to:
  /// **'No active alerts'**
  String get noActiveAlerts;

  /// No description provided for @criticalDensityStatus.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get criticalDensityStatus;

  /// No description provided for @highDensityStatus.
  ///
  /// In en, this message translates to:
  /// **'High Density'**
  String get highDensityStatus;

  /// No description provided for @normalDensityStatus.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normalDensityStatus;

  /// No description provided for @capacityLabel.
  ///
  /// In en, this message translates to:
  /// **'% Capacity'**
  String get capacityLabel;

  /// No description provided for @currentAvgDensityValue.
  ///
  /// In en, this message translates to:
  /// **'{value} Avg. Density'**
  String currentAvgDensityValue(Object value);

  /// No description provided for @aboveRecommended.
  ///
  /// In en, this message translates to:
  /// **'Above Recommended'**
  String get aboveRecommended;

  /// No description provided for @reportButtonShort.
  ///
  /// In en, this message translates to:
  /// **'Report...'**
  String get reportButtonShort;

  /// No description provided for @viewAlertsShort.
  ///
  /// In en, this message translates to:
  /// **'View A...'**
  String get viewAlertsShort;

  /// No description provided for @emergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergencyTitle;

  /// No description provided for @evacuationWarning.
  ///
  /// In en, this message translates to:
  /// **'This will trigger an evacuation alert for all attendees and staff in venue. This action cannot be undone.'**
  String get evacuationWarning;

  /// No description provided for @evacuationOrderMessage.
  ///
  /// In en, this message translates to:
  /// **'EVACUATION ORDER: All attendees and staff must evacuate venue immediately. Follow emergency exit routes.'**
  String get evacuationOrderMessage;

  /// No description provided for @minutesAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgoShort(Object minutes);

  /// No description provided for @allIncidentsTitle.
  ///
  /// In en, this message translates to:
  /// **'All Incidents'**
  String get allIncidentsTitle;

  /// No description provided for @noActiveIncidents.
  ///
  /// In en, this message translates to:
  /// **'No Active Incidents'**
  String get noActiveIncidents;

  /// No description provided for @allEmergenciesResolved.
  ///
  /// In en, this message translates to:
  /// **'All emergencies have been resolved'**
  String get allEmergenciesResolved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
