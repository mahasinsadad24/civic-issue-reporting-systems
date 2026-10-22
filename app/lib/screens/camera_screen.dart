import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../styles/app_theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isRearCameraSelected = true;
  bool _isFlashOn = false;
  String? _capturedImagePath;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final permission = await Permission.camera.request();
    if (permission != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        await _initController(_cameras[0]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing camera: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _initController(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing camera: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (!_isCameraInitialized || _controller == null) return;

    try {
      final XFile photo = await _controller!.takePicture();
      setState(() {
        _capturedImagePath = photo.path;
        _showPreview = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing photo: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _isRearCameraSelected = !_isRearCameraSelected;
      _isCameraInitialized = false;
    });

    await _initController(
      _isRearCameraSelected ? _cameras[0] : _cameras[1],
    );
  }

  Future<void> _toggleFlash() async {
    if (!_isCameraInitialized || _controller == null) return;

    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImagePath = null;
      _showPreview = false;
    });
  }

  void _confirmPhoto() {
    if (_capturedImagePath != null) {
      Navigator.pop(context, _capturedImagePath);
    }
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }

    return CameraPreview(_controller!);
  }

  Widget _buildPhotoPreview() {
    if (_capturedImagePath == null) return Container();

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Image.file(
        File(_capturedImagePath!),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildCameraControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(
                red: 0, green: 0, blue: 0, alpha: 204), // 0.8 opacity
            Colors.black.withValues(
                red: 0, green: 0, blue: 0, alpha: 77), // 0.3 opacity
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Flash toggle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                        red: 0, green: 0, blue: 0, alpha: 128), // 0.5 opacity
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _toggleFlash,
                    icon: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: _isFlashOn ? AppTheme.warningColor : Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                // Capture button
                GestureDetector(
                  onTap: _capturePhoto,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 4,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppTheme.primaryColor,
                      size: 32,
                    ),
                  ),
                ),
                // Camera toggle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                        red: 0, green: 0, blue: 0, alpha: 128), // 0.5 opacity
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _cameras.length > 1 ? _toggleCamera : null,
                    icon: Icon(
                      Icons.flip_camera_ios,
                      color: _cameras.length > 1 ? Colors.white : Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(
                red: 0, green: 0, blue: 0, alpha: 204), // 0.8 opacity
            Colors.black.withValues(
                red: 0, green: 0, blue: 0, alpha: 77), // 0.3 opacity
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Retake button
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: ElevatedButton.icon(
                      onPressed: _retakePhoto,
                      icon: const Icon(Icons.refresh_rounded,
                          color: Colors.white),
                      label: const Text(
                        'Retake',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withValues(
                            red: 0,
                            green: 0,
                            blue: 0,
                            alpha: 179), // 0.7 opacity
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.white54),
                        ),
                      ),
                    ),
                  ),
                ),
                // Confirm button
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    child: ElevatedButton.icon(
                      onPressed: _confirmPhoto,
                      icon:
                          const Icon(Icons.check_rounded, color: Colors.white),
                      label: const Text(
                        'Use Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          _showPreview ? 'Photo Preview' : 'Take Photo',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Camera preview or photo preview
          if (_showPreview) _buildPhotoPreview() else _buildCameraPreview(),

          // Controls overlay
          Positioned.fill(
            child:
                _showPreview ? _buildPreviewControls() : _buildCameraControls(),
          ),
        ],
      ),
    );
  }
}
