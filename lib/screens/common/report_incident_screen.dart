import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/gradient_scaffold.dart';
import '../../widgets/common/glass_card.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _descriptionController = TextEditingController();
  String _selectedType = 'security';
  String _selectedSeverity = 'medium';
  final List<XFile> _images = [];
  bool _isSubmitting = false;
  final _imagePicker = ImagePicker();

  final List<Map<String, dynamic>> _incidentTypes = [
    {'value': 'medical', 'label': 'Medical', 'icon': Icons.medical_services},
    {'value': 'security', 'label': 'Security', 'icon': Icons.security},
    {'value': 'overcrowding', 'label': 'Overcrowding', 'icon': Icons.groups},
    {'value': 'facility', 'label': 'Facility', 'icon': Icons.build},
    {'value': 'other', 'label': 'Other', 'icon': Icons.report},
  ];

  final List<Map<String, dynamic>> _severityLevels = [
    {'value': 'low', 'label': 'Low', 'color': AppColors.green},
    {'value': 'medium', 'label': 'Medium', 'color': AppColors.yellow},
    {'value': 'high', 'label': 'High', 'color': AppColors.orange},
    {'value': 'critical', 'label': 'Critical', 'color': AppColors.red},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() => _images.add(image));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2A3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white70),
                title: Text('Camera', style: GoogleFonts.roboto(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white70),
                title: Text('Gallery', style: GoogleFonts.roboto(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the incident'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final incidentProvider = Provider.of<IncidentProvider>(context, listen: false);
      final user = authProvider.currentUser!;

      // Upload images if any
      List<String>? imageUrls;
      if (_images.isNotEmpty) {
        final storageService = StorageService();
        final incidentId = DateTime.now().millisecondsSinceEpoch.toString();
        final imageFiles = _images.map((x) => File(x.path)).toList();
        final urls = await storageService.uploadIncidentImages(
          incidentId: incidentId,
          imageFiles: imageFiles,
        );
        if (urls.isNotEmpty) imageUrls = urls;
      }

      // Default location (King Fahd Stadium, Riyadh)
      const defaultLocation = LatLng(24.7136, 46.6753);

      final success = await incidentProvider.reportIncident(
        eventId: 'current_event',
        reportedBy: user.id,
        reportedByName: user.name,
        location: defaultLocation,
        type: _selectedType,
        description: _descriptionController.text.trim(),
        severity: _selectedSeverity,
        imageUrls: imageUrls,
      );

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incident reported successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(incidentProvider.errorMessage ?? 'Failed to report incident'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Report Incident',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Incident Type
                    _buildSectionLabel('Incident Type'),
                    const SizedBox(height: 10),
                    _buildTypeSelector(),
                    const SizedBox(height: 24),

                    // Severity
                    _buildSectionLabel('Severity Level'),
                    const SizedBox(height: 10),
                    _buildSeveritySelector(),
                    const SizedBox(height: 24),

                    // Description
                    _buildSectionLabel('Description'),
                    const SizedBox(height: 10),
                    _buildDescriptionField(),
                    const SizedBox(height: 24),

                    // Photos
                    _buildSectionLabel('Photos (Optional)'),
                    const SizedBox(height: 10),
                    _buildImageSection(),
                    const SizedBox(height: 32),

                    // Submit Button
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _incidentTypes.map((type) {
        final isSelected = _selectedType == type['value'];
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type['value']),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.softTealBlue.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.softTealBlue : Colors.white24,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type['icon'] as IconData,
                  color: isSelected ? AppColors.softTealBlue : Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  type['label'] as String,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.softTealBlue : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeveritySelector() {
    return Row(
      children: _severityLevels.map((level) {
        final isSelected = _selectedSeverity == level['value'];
        final color = level['color'] as Color;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedSeverity = level['value']),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : Colors.white24,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.white24,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    level['label'] as String,
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? color : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      maxLines: 4,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Describe what happened...',
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF0D1B2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.softTealBlue),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        // Image previews
        if (_images.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: FileImage(File(_images[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 14,
                      child: GestureDetector(
                        onTap: () => setState(() => _images.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

        if (_images.isNotEmpty) const SizedBox(height: 12),

        // Add photo button
        GestureDetector(
          onTap: _images.length < 3 ? _showImageSourcePicker : null,
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  color: _images.length < 3 ? Colors.white70 : Colors.white30,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  _images.isEmpty
                      ? 'Add Photos'
                      : '${_images.length}/3 photos added',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: _images.length < 3 ? Colors.white70 : Colors.white30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _submitReport,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _isSubmitting ? Colors.grey : AppColors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isSubmitting
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Submit Incident Report',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
