import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../styles/app_theme.dart';

class VideoUploadWidget extends StatefulWidget {
  final Function(File videoFile) onVideoSelected;

  const VideoUploadWidget({
    super.key,
    required this.onVideoSelected,
  });

  @override
  State<VideoUploadWidget> createState() => _VideoUploadWidgetState();
}

class _VideoUploadWidgetState extends State<VideoUploadWidget>
    with SingleTickerProviderStateMixin {
  File? _selectedVideo;
  VideoPlayerController? _videoController;
  bool _isLoading = false;
  bool _isPlaying = false;
  double _uploadProgress = 0.0;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final videoFile = File(result.files.single.path!);
        final fileSize = await videoFile.length();

        // Check file size (limit to 100MB)
        if (fileSize > 100 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Video file is too large. Please select a file under 100MB.'),
                backgroundColor: AppTheme.warningColor,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedVideo = videoFile;
        });

        await _initializeVideoPlayer(videoFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting video: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initializeVideoPlayer(File videoFile) async {
    try {
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(videoFile);
      await _videoController!.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing video player: $e');
    }
  }

  void _togglePlayPause() {
    if (_videoController == null) return;

    setState(() {
      if (_isPlaying) {
        _videoController!.pause();
        _isPlaying = false;
      } else {
        _videoController!.play();
        _isPlaying = true;
      }
    });
  }

  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) return;

    setState(() {
      _uploadProgress = 0.0;
    });

    // Simulate upload progress
    _progressController.addListener(() {
      setState(() {
        _uploadProgress = _progressAnimation.value;
      });
    });

    _progressController.forward().then((_) {
      if (mounted) {
        Navigator.pop(context);
        widget.onVideoSelected(_selectedVideo!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video uploaded successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    });
  }

  void _removeVideo() {
    setState(() {
      _selectedVideo = null;
      _videoController?.dispose();
      _videoController = null;
      _isPlaying = false;
      _uploadProgress = 0.0;
    });
    _progressController.reset();
  }

  Widget _buildVideoPreview() {
    if (_selectedVideo == null || _videoController == null) {
      return Container();
    }

    if (!_videoController!.value.isInitialized) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Video player
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),

            // Play/pause overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(
                          red: 0, green: 0, blue: 0, alpha: 77), // 0.3 opacity
                      Colors.transparent,
                      Colors.black.withValues(
                          red: 0, green: 0, blue: 0, alpha: 77), // 0.3 opacity
                    ],
                  ),
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                            red: 0,
                            green: 0,
                            blue: 0,
                            alpha: 179), // 0.7 opacity
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Remove button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _removeVideo,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),

            // Video duration
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatDuration(_videoController!.value.duration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _isLoading ? null : _pickVideo,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.secondaryColor.withValues(alpha: 0.1),
              AppTheme.primaryColor.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(
            color: AppTheme.secondaryColor.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              Column(
                children: [
                  const CircularProgressIndicator(
                    color: AppTheme.secondaryColor,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading video...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.neutral600,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.videocam_rounded,
                      color: AppTheme.secondaryColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Video',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'MP4, MOV up to 100MB',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.neutral500,
                        ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Column(
      children: [
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: _uploadProgress,
          backgroundColor: AppTheme.neutral300,
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppTheme.successColor),
          minHeight: 6,
        ),
        const SizedBox(height: 8),
        Text(
          'Uploading... ${(_uploadProgress * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.neutral600,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.neutral100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: AppTheme.neutral600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Upload Video',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.neutral800,
                              ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the close button
                ],
              ),

              const SizedBox(height: 20),

              // Video preview or upload area
              _selectedVideo != null
                  ? _buildVideoPreview()
                  : _buildUploadArea(),

              // Upload progress
              if (_uploadProgress > 0 && _uploadProgress < 1)
                _buildUploadProgress(),

              // Video info
              if (_selectedVideo != null && _uploadProgress == 0) ...[
                const SizedBox(height: 16),
                FutureBuilder<int>(
                  future: _selectedVideo!.length(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppTheme.secondaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Video ready for upload',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.secondaryColor,
                                        ),
                                  ),
                                  Text(
                                    'Size: ${_formatFileSize(snapshot.data!)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.neutral600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ],

              // Action buttons
              if (_selectedVideo != null && _uploadProgress == 0) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _removeVideo,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.neutral400),
                        ),
                        child: const Text('Remove'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _uploadVideo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Upload Video'),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
