import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import '../styles/app_theme.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(String audioPath, Duration duration) onRecordingComplete;

  const VoiceRecorderWidget({
    super.key,
    required this.onRecordingComplete,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with TickerProviderStateMixin {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String? _audioPath;

  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  final List<double> _waveAmplitudes = List.generate(20, (index) => 0.0);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeRecorder();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    _recorder?.closeRecorder();
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
  }

  Future<void> _startRecording() async {
    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Microphone permission is required for voice recording'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
      }
      return;
    }

    try {
      final directory = Directory.systemTemp;
      _audioPath =
          '${directory.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder!.startRecorder(
        toFile: _audioPath,
        codec: Codec.aacADTS,
      );

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration = Duration(seconds: timer.tick);
        });
        _updateWaveAmplitudes();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting recording: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _updateWaveAmplitudes() {
    // Simulate wave amplitudes for visual feedback
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    for (int i = 0; i < _waveAmplitudes.length; i++) {
      _waveAmplitudes[i] = (random + i * 10) % 100 / 100.0;
    }
    _waveController.forward().then((_) => _waveController.reverse());
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder!.stopRecorder();
      _recordingTimer?.cancel();

      setState(() {
        _isRecording = false;
      });

      if (!mounted) return;
      if (_audioPath != null) {
        Navigator.pop(context);
        widget.onRecordingComplete(_audioPath!, _recordingDuration);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error stopping recording: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _cancelRecording() {
    if (_isRecording) {
      _recorder!.stopRecorder();
      _recordingTimer?.cancel();

      if (_audioPath != null) {
        File(_audioPath!).delete();
      }
    }
    Navigator.pop(context);
  }

  Widget _buildWaveForm() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _waveAmplitudes.map((amplitude) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 3,
            height: _isRecording ? 20 + (amplitude * 40) : 20,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: _isRecording
                  ? AppTheme.accentColor.withValues(alpha: 0.7 + amplitude * 0.3)
                  : AppTheme.neutral400,
              borderRadius: BorderRadius.circular(1.5),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecordButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isRecording ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _isRecording ? AppTheme.errorColor : AppTheme.accentColor,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording
                            ? AppTheme.errorColor
                            : AppTheme.accentColor)
                        .withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _cancelRecording,
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: AppTheme.neutral600,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _isRecording ? 'Recording...' : 'Voice Recording',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.neutral800,
                              ),
                        ),
                        if (_isRecording)
                          Text(
                            _formatDuration(_recordingDuration),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.accentColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the close button
                ],
              ),
            ),

            // Wave form visualization
            _buildWaveForm(),

            const SizedBox(height: 40),

            // Record button
            _buildRecordButton(),

            const SizedBox(height: 30),

            // Instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _isRecording
                    ? 'Tap to stop recording'
                    : 'Tap to start recording your voice message',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.neutral600,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
