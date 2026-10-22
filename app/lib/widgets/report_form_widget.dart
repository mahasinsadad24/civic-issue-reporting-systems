import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:ui';
import '../styles/app_theme.dart';
import '../services/location_service.dart';
import '../screens/camera_screen.dart';
import '../providers/reports_provider.dart';
import '../widgets/voice_recorder_widget.dart';
import '../widgets/video_upload_widget.dart';
import 'package:civic_issue_reporter/l10n/generated/app_localizations.dart';

class ReportFormWidget extends StatefulWidget {
  const ReportFormWidget(
      {super.key, required Null Function(dynamic report) onSubmitted});

  @override
  State<ReportFormWidget> createState() => _ReportFormWidgetState();
}

class _ReportFormWidgetState extends State<ReportFormWidget> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<File> _selectedImages = [];
  final LocationService _locationService = LocationService();
  bool _isGettingLocation = false;
  Map<String, dynamic>? _locationData;

  // Voice recording properties
  String? _audioPath;

  // Video properties
  File? _selectedVideo;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                Color(0xFF0D47A1)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_location_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.reportTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.neutral800,
                                  ),
                            ),
                            Text(
                              'Help us fix issues in your area',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.neutral500,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Location Input
                    _buildSectionHeader(
                        AppLocalizations.of(context)!.locationLabel,
                        Icons.place_rounded),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.neutral100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _locationController,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText:
                                    AppLocalizations.of(context)!.locationHint,
                                hintStyle:
                                    const TextStyle(color: AppTheme.neutral500),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 1,
                            color: AppTheme.neutral300,
                          ),
                          IconButton(
                            onPressed:
                                _isGettingLocation ? null : _getCurrentLocation,
                            icon: _isGettingLocation
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.primaryColor,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.my_location_rounded),
                            color: AppTheme.primaryColor,
                            tooltip: AppLocalizations.of(context)!
                                .getLocationTooltip,
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description Input
                    _buildSectionHeader(
                        AppLocalizations.of(context)!.descriptionLabel,
                        Icons.description_rounded),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.neutral100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)!.descriptionHint,
                          hintStyle:
                              const TextStyle(color: AppTheme.neutral500),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Media Selection
                    _buildSectionHeader(
                        AppLocalizations.of(context)!.addPhotosLabel,
                        Icons.perm_media_rounded),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildMediaButton(
                            icon: Icons.camera_alt_rounded,
                            label: 'Camera',
                            onTap: _takePhotoFromCamera,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          _buildMediaButton(
                            icon: Icons.image_rounded,
                            label: 'Gallery',
                            onTap: _pickImages,
                            color: Colors.purple,
                          ),
                          const SizedBox(width: 12),
                          _buildMediaButton(
                            icon: Icons.videocam_rounded,
                            label: 'Video',
                            onTap: _pickVideo,
                            color: AppTheme.secondaryColor,
                          ),
                          const SizedBox(width: 12),
                          _buildMediaButton(
                            icon: Icons.mic_rounded,
                            label: 'Audio',
                            onTap: _handleVoiceRecording,
                            color: AppTheme.accentColor,
                          ),
                        ],
                      ),
                    ),

                    // Media Previews
                    if (_selectedImages.isNotEmpty ||
                        _selectedVideo != null ||
                        _audioPath != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 80,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ..._selectedImages.asMap().entries.map(
                                  (entry) => _buildImagePreview(
                                      entry.value, entry.key),
                                ),
                            if (_selectedVideo != null)
                              _buildVideoPreview(_selectedVideo!),
                            if (_audioPath != null) _buildAudioPreview(),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _canSubmit() ? _submitReport : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          disabledBackgroundColor: AppTheme.neutral300,
                          elevation: _canSubmit() ? 8 : 0,
                          shadowColor:
                              AppTheme.primaryColor.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.submitReport,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (_canSubmit()) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 20),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // Add extra padding at the bottom for scroll comfort
                    const SizedBox(height: 300),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.neutral600,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(File image, int index) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(image, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(File video) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.secondaryColor.withValues(alpha: 0.1),
        border:
            Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.3)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.videocam_rounded,
              color: AppTheme.secondaryColor, size: 30),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedVideo = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPreview() {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.accentColor.withValues(alpha: 0.1),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.mic_rounded, color: AppTheme.accentColor, size: 30),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _audioPath = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    return _descriptionController.text.trim().isNotEmpty;
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((image) => File(image.path)).toList();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _handleVoiceRecording() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceRecorderWidget(
        onRecordingComplete: (audioPath, duration) {
          setState(() {
            _audioPath = audioPath;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.voiceRecordingAttached),
              backgroundColor: AppTheme.successColor,
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickVideo() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VideoUploadWidget(
        onVideoSelected: (videoFile) {
          setState(() {
            _selectedVideo = videoFile;
          });
        },
      ),
    );
  }

  Future<void> _takePhotoFromCamera() async {
    try {
      final String? imagePath = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => const CameraScreen(),
        ),
      );

      if (imagePath != null && mounted) {
        setState(() {
          _selectedImages.add(File(imagePath));
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.photoSuccess),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.errorGeneric(e.toString())),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      _locationData = await _locationService.getLocationDataForBackend();

      if (_locationData != null) {
        setState(() {
          _locationController.text = _locationData!['address'] ??
              'Lat: ${_locationData!['latitude']?.toStringAsFixed(6)}, '
                  'Lng: ${_locationData!['longitude']?.toStringAsFixed(6)}';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.locationSuccess),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.locationError),
              backgroundColor: AppTheme.warningColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error getting location. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _submitReport() async {
    if (_canSubmit()) {
      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.submittingReport,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        );

        // Submit report using provider with auto-classification
        final reportsProvider =
            Provider.of<ReportsProvider>(context, listen: false);

        // Auto-detect category based on image and text (placeholder for ML integration)
        String detectedCategory =
            'other'; // This will be replaced by ML classification

        await reportsProvider.submitNewReport(
          title: 'General Issue', // Human readable title
          category: detectedCategory, // Backend valid enum
          description: _descriptionController.text.trim(),
          location: _locationController.text.isNotEmpty
              ? _locationController.text.trim()
              : null,
          hasAttachments: _selectedImages.isNotEmpty ||
              _audioPath != null ||
              _selectedVideo != null,
          images: _selectedImages, // Pass images for ML classification
        );

        // Send location data to backend if available
        if (_locationData != null) {
          await _locationService.sendLocationToBackend(_locationData!);
        }

        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppTheme.successColor),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.reportSuccessTitle),
                ],
              ),
              content: Text(
                AppLocalizations.of(context)!.reportSuccessMessage,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Close bottom sheet
                    _clearForm();
                    // Navigate to reports to see the new report
                    Navigator.pushNamed(context, '/reports');
                  },
                  child: Text(AppLocalizations.of(context)!.viewReports),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        // Close loading dialog if it's open
        if (mounted) {
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.errorGeneric(e.toString())),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _clearForm() {
    setState(() {
      _descriptionController.clear();
      _locationController.clear();
      _selectedImages.clear();
      _locationData = null;
      _isGettingLocation = false;
      _audioPath = null;
      _selectedVideo = null;
    });
    _locationService.clearLocationData();
  }
}
