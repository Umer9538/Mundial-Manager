import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/gradient_scaffold.dart';
import '../../widgets/common/glass_card.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Privacy Policy',
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
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.softTealBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.softTealBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mundial Manager',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Last updated: January 2026',
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Introduction
            _PolicySection(
              title: 'Introduction',
              content:
                  'Mundial Manager ("we", "our", or "the App") is committed to protecting '
                  'your privacy and ensuring the security of your personal information. '
                  'This Privacy Policy explains how we collect, use, disclose, and safeguard '
                  'your information when you use our crowd management application during '
                  'FIFA World Cup events and related gatherings.\n\n'
                  'By using the App, you consent to the practices described in this policy.',
            ),
            const SizedBox(height: 16),

            // Data Collection
            _PolicySection(
              title: '1. Data Collection',
              content:
                  'We collect the following types of information:\n\n'
                  'Anonymous Location Data: When you enable location sharing, we collect '
                  'your real-time geographic coordinates to monitor crowd density and '
                  'ensure public safety. Location data is anonymized and cannot be '
                  'directly linked to your personal identity during processing.\n\n'
                  'Account Information: When you register, we collect your name, email '
                  'address, and role (fan, organizer, security, or emergency services). '
                  'Phone numbers are optional.\n\n'
                  'Usage Data: We collect anonymized data about how you interact with '
                  'the App, including feature usage, alert acknowledgments, and incident '
                  'reports, solely for improving safety outcomes.\n\n'
                  'Device Information: We may collect device type and operating system '
                  'version for compatibility and notification delivery purposes.',
            ),
            const SizedBox(height: 16),

            // Consent
            _PolicySection(
              title: '2. Consent & Location Sharing',
              content:
                  'Location sharing is entirely optional. You may enable or disable '
                  'location sharing at any time through the App settings or your '
                  'device settings.\n\n'
                  'When enabled, your location is used exclusively for:\n'
                  '  - Real-time crowd density monitoring\n'
                  '  - Emergency alert delivery based on proximity\n'
                  '  - Evacuation route optimization\n'
                  '  - Safety incident response coordination\n\n'
                  'We never sell, share, or use your location data for advertising, '
                  'marketing, or any purpose unrelated to event safety management.\n\n'
                  'You will be prompted for explicit consent before any location data '
                  'is collected, and you can revoke this consent at any time.',
            ),
            const SizedBox(height: 16),

            // GDPR Rights
            _PolicySection(
              title: '3. Your Rights (GDPR Compliance)',
              content:
                  'Under the General Data Protection Regulation (GDPR) and applicable '
                  'data protection laws, you have the following rights:\n\n'
                  'Right of Access: You may request a copy of the personal data we '
                  'hold about you.\n\n'
                  'Right to Rectification: You may request correction of inaccurate '
                  'or incomplete personal data.\n\n'
                  'Right to Erasure ("Right to be Forgotten"): You may request '
                  'deletion of your personal data, subject to legal retention requirements.\n\n'
                  'Right to Restrict Processing: You may request that we limit '
                  'how we use your data.\n\n'
                  'Right to Data Portability: You may request your data in a '
                  'structured, machine-readable format.\n\n'
                  'Right to Object: You may object to processing of your data '
                  'for specific purposes.\n\n'
                  'Right to Withdraw Consent: You may withdraw previously given '
                  'consent at any time without affecting the lawfulness of prior processing.\n\n'
                  'To exercise any of these rights, please contact us using the '
                  'information provided below.',
            ),
            const SizedBox(height: 16),

            // Data Retention
            _PolicySection(
              title: '4. Data Retention',
              content:
                  'We retain your data only as long as necessary:\n\n'
                  'Location Data: Anonymized crowd density data is retained for '
                  'a maximum of 30 days after the event concludes, then permanently '
                  'deleted.\n\n'
                  'Account Data: Your account information is retained for the '
                  'duration of your active account. Upon account deletion, all '
                  'personal data is removed within 30 days.\n\n'
                  'Incident Reports: Reports involving safety incidents may be '
                  'retained for up to 30 days for regulatory compliance and '
                  'post-event safety analysis, after which they are anonymized.\n\n'
                  'Analytics Data: Aggregated, non-identifiable analytics data '
                  'may be retained indefinitely for improving future event safety.\n\n'
                  'All data retention periods comply with applicable local and '
                  'international data protection regulations.',
            ),
            const SizedBox(height: 16),

            // Security Measures
            _PolicySection(
              title: '5. Security Measures',
              content:
                  'We implement industry-standard security measures to protect your data:\n\n'
                  'Encryption: All data is encrypted in transit using TLS 1.3 and '
                  'at rest using AES-256 encryption.\n\n'
                  'Access Controls: Strict role-based access controls ensure only '
                  'authorized personnel can access specific data categories.\n\n'
                  'Infrastructure: Our backend services are hosted on Firebase / '
                  'Google Cloud Platform, which maintains SOC 2, ISO 27001, and '
                  'other security certifications.\n\n'
                  'Monitoring: We employ continuous monitoring and logging to detect '
                  'and respond to potential security threats.\n\n'
                  'Data Minimization: We collect only the minimum amount of data '
                  'necessary for crowd safety management.\n\n'
                  'While we strive to protect your information, no method of '
                  'electronic transmission or storage is 100% secure. We encourage '
                  'you to use strong passwords and keep your credentials confidential.',
            ),
            const SizedBox(height: 16),

            // Third Parties
            _PolicySection(
              title: '6. Third-Party Services',
              content:
                  'The App uses the following third-party services:\n\n'
                  '  - Firebase (Google): Authentication, database, and cloud messaging\n'
                  '  - OpenStreetMap: Map tile rendering\n'
                  '  - Google Fonts: Typography rendering\n\n'
                  'Each third-party service operates under its own privacy policy. '
                  'We recommend reviewing their policies for a complete understanding '
                  'of their data practices.',
            ),
            const SizedBox(height: 16),

            // Contact Information
            _PolicySection(
              title: '7. Contact Information',
              content:
                  'If you have questions, concerns, or requests regarding this '
                  'Privacy Policy or your personal data, please contact us:\n\n'
                  'Email: privacy@mundialmanager.com\n'
                  'Data Protection Officer: dpo@mundialmanager.com\n\n'
                  'For GDPR-related inquiries, you also have the right to lodge a '
                  'complaint with your local data protection authority.\n\n'
                  'We aim to respond to all privacy-related requests within 30 days.',
            ),
            const SizedBox(height: 16),

            // Changes to Policy
            _PolicySection(
              title: '8. Changes to This Policy',
              content:
                  'We may update this Privacy Policy from time to time. Any changes '
                  'will be posted within the App and, for significant changes, we '
                  'will notify you via email or in-app notification.\n\n'
                  'Your continued use of the App after changes are posted constitutes '
                  'your acceptance of the updated policy.\n\n'
                  'We encourage you to review this policy periodically for any updates.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
