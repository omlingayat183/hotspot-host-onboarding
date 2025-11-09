import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotspot_host_onboarding/widgets/audio_recorded_card.dart' hide Fx;
import 'package:hotspot_host_onboarding/widgets/shared_ui_widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

import '../../state/onboarding_providers.dart';
import '../../data/models/experience.dart';

class OnboardingQuestionScreen extends ConsumerStatefulWidget {
  final Experience? selectedExperience;

  const OnboardingQuestionScreen({super.key, this.selectedExperience});

  @override
  ConsumerState<OnboardingQuestionScreen> createState() => _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState extends ConsumerState<OnboardingQuestionScreen> {
  final _recorder = AudioRecorder();
  final _text = TextEditingController();
  RecorderController? _waveController;
  final FocusNode _focus = FocusNode();

  CameraController? _cam;
  VideoPlayerController? _vp;

  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    _waveController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _recorder.dispose();
    _waveController?.dispose();
    _cam?.dispose();
    _vp?.dispose();
    _focus.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<String> _nextAudioPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '${dir.path}/onboarding_$ts.m4a';
  }

  Future<void> _startAudio() async {
    if (!await Permission.microphone.request().isGranted) return;
    if (!await _recorder.hasPermission()) return;

    final out = await _nextAudioPath();
    ref.read(onboardingQProvider.notifier).setRecording(true);
    _elapsed = Duration.zero;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: out,
    );
    _waveController?.record();
  }

  Future<void> _cancelAudio() async {
    if (await _recorder.isRecording()) {
      final path = await _recorder.stop();
      if (path != null) {
        try {
          final f = File(path);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
    }
    _ticker?.cancel();
    _elapsed = Duration.zero;
    await _waveController?.stop();
    ref.read(onboardingQProvider.notifier).setRecording(false);
  }

  Future<void> _stopAudio() async {
    final path = await _recorder.stop();
    _ticker?.cancel();
    await _waveController?.stop();
    ref.read(onboardingQProvider.notifier).setRecording(false);
    if (path != null && path.isNotEmpty) {
      ref.read(onboardingQProvider.notifier).setAudio(path);
    }
    setState(() {});
  }

  Future<void> _deleteAudio() async {
    final p = ref.read(onboardingQProvider).audioPath;
    if (p == null) return;
    try {
      final f = File(p);
      final exists = await f.exists();
      if (!exists) {
        ref.read(onboardingQProvider.notifier).setAudio(null);
        if (mounted) setState(() {});
        return;
      }
      final tmp = '${p}.deleting';
      try {
        await f.rename(tmp);
        final tfile = File(tmp);
        await tfile.delete();
      } catch (_) {
        try {
          await f.delete();
        } catch (_) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(content: Text('Could not delete file — it may be in use.')));
          return;
        }
      }
      ref.read(onboardingQProvider.notifier).setAudio(null);
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _initCameraIfNeeded() async {
    if (_cam != null) return;
    if (!await Permission.camera.request().isGranted) return;
    final cams = await availableCameras();
    final prefer = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cams.first);
    _cam = CameraController(prefer, ResolutionPreset.medium, enableAudio: true);
    await _cam!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _recordVideo() async {
    await _initCameraIfNeeded();
    if (_cam == null) return;
    if (_cam!.value.isRecordingVideo) return;
    await _cam!.startVideoRecording();
    setState(() {});
  }

  Future<void> _stopVideo() async {
    if (_cam == null || !_cam!.value.isRecordingVideo) return;
    final file = await _cam!.stopVideoRecording();
    ref.read(onboardingQProvider.notifier).setVideo(file.path);

    _vp?.dispose();
    _vp = VideoPlayerController.file(File(file.path));
    await _vp!.initialize();
    setState(() {});
  }

  Future<void> _deleteVideo() async {
    final p = ref.read(onboardingQProvider).videoPath;
    if (p != null) {
      try {
        final f = File(p);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    _vp?.dispose();
    _vp = null;
    ref.read(onboardingQProvider.notifier).setVideo(null);
    setState(() {});
  }

  String _mmss(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(onboardingQProvider);

    final hasAudio = st.audioPath != null;
    final hasVideo = st.videoPath != null;
    final showRecordButtons = !(hasAudio && hasVideo);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: Fx.bg,
      body: SafeArea(
        child: Stack(
          children: [
            const WavyBackgroundPattern(angle: -0.40, color: Color(0x0AFFFFFF)),

            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + bottomInset + 96),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TopBar(progressFraction: 0.66),
                  const SizedBox(height: 10),

                  Text(
                    '02',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(.06),
                          fontWeight: FontWeight.w600,
                          letterSpacing: .3,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 6),

                  // selected experience preview
                  if (widget.selectedExperience != null) ...[
                    SizedBox(
                      height: 88,
                      child: Row(
                        children: [
                          TiltedStamp(
                            angleDeg: -4.0,
                            selected: true,
                            child: Container(
                              width: 120,
                              height: 88,
                              color: Colors.black26,
                              child: widget.selectedExperience!.imageUrl != null && widget.selectedExperience!.imageUrl!.isNotEmpty
                                  ? Image.network(widget.selectedExperience!.imageUrl!, fit: BoxFit.cover)
                                  : const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(widget.selectedExperience!.tagline ?? 'Selected', maxLines: 2, overflow: TextOverflow.ellipsis, style: Fx.h1(context).copyWith(fontSize: 16)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  Text(
                    'Why do you want to host with us?',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Fx.h1(context).copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Tell us about your intent and what motivates you to create experiences.',
                    style: Fx.bodyDim,
                  ),
                  const SizedBox(height: 14),

                  GlassTextField(
                    controller: _text,
                    focusNode: _focus,
                    hint: '/ Start typing here',
                    onChanged: (v) => ref.read(onboardingQProvider.notifier).setAnswer(v),
                    minLines: 4,
                    maxLines: 6,
                    maxLength: 600,
                  ),
                  const SizedBox(height: 16),

                  // Audio / video sections
                  if (st.isRecordingAudio) ...[
                    RecordingCard(
                      waveController: _waveController!,
                      timerText: _mmss(_elapsed),
                      onCancel: _cancelAudio,
                      onStop: _stopAudio,
                    ),
                    const SizedBox(height: 12),
               ] else if (hasAudio) ...[
  AudioRecordedCard(
    filePath: st.audioPath!,
    onDelete: _deleteAudio,
  ),
  const SizedBox(height: 12),
],

                  if (hasVideo) ...[
                    MediaChip(icon: Icons.videocam, label: 'Video Recorded', onDelete: _deleteVideo),
                    const SizedBox(height: 12),
                  ],

                  SizedBox(height: 40 + bottomPad),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 12 + bottomPad),
                decoration: BoxDecoration(
                  color: Fx.bg.withOpacity(0.0),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.45), blurRadius: 24, offset: const Offset(0, -8))],
                ),
                child: _BottomActionRow(
                  micEnabled: !st.isRecordingAudio && st.audioPath == null,
                  camEnabled: !st.isRecordingAudio && st.videoPath == null,
                  micActive: st.isRecordingAudio,
                  isCamRecording: _cam?.value.isRecordingVideo ?? false,
                  showRecordButtons: showRecordButtons,
                  onMic: _startAudio,
                  onCamStart: _recordVideo,
                  onCamStop: _stopVideo,
                  onNext: () {
                    final payload = {
                      'answer': st.longAnswer,
                      'audio_path': st.audioPath,
                      'video_path': st.videoPath,
                    };
                    debugPrint('Onboarding submission: $payload');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('State logged to console')));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionRow extends StatelessWidget {
  final bool micEnabled;
  final bool camEnabled;
  final bool micActive;
  final bool isCamRecording;
  final bool showRecordButtons;
  final VoidCallback onMic;
  final VoidCallback onCamStart;
  final VoidCallback onCamStop;
  final VoidCallback onNext;

  const _BottomActionRow({
    required this.micEnabled,
    required this.camEnabled,
    required this.micActive,
    required this.isCamRecording,
    required this.showRecordButtons,
    required this.onMic,
    required this.onCamStart,
    required this.onCamStop,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const double smallBtnWidth = 56;
    const double rowHeight = 64;
    const double gap = 12;
    const duration = Duration(milliseconds: 300);

    Widget smallButton({required IconData icon, required bool enabled, required bool active, required VoidCallback onTap}) {
      final bgColor = enabled ? (active ? Fx.primaryAccent.withOpacity(.22) : Colors.white.withOpacity(.02)) : Colors.white.withOpacity(.01);
      final border = enabled ? BorderSide(color: Colors.white.withOpacity(.06), width: 1) : BorderSide(color: Colors.white.withOpacity(.04), width: 1);
      final iconColor = enabled ? (active ? Colors.white : Colors.white70) : Colors.white24;

      return SizedBox(
        width: smallBtnWidth,
        height: rowHeight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.fromBorderSide(border)),
              child: Center(child: Icon(icon, color: iconColor, size: 22)),
            ),
          ),
        ),
      );
    }

    Widget camBtn() {
      final camActive = isCamRecording;
      final enabled = camEnabled || camActive;
      return smallButton(icon: camActive ? Icons.videocam_off : Icons.videocam, enabled: enabled, active: camActive, onTap: () => camActive ? onCamStop() : onCamStart());
    }

    Widget micBtn() {
      final enabled = micEnabled || micActive;
      return smallButton(icon: micActive ? Icons.mic : Icons.mic_none, enabled: enabled, active: micActive, onTap: onMic);
    }

    return AnimatedSize(
      duration: duration,
      curve: Curves.easeInOut,
      child: AnimatedSwitcher(
        duration: duration,
        child: showRecordButtons
            ? Row(
                key: const ValueKey('three_buttons'),
                children: [
                  micBtn(),
                  const SizedBox(width: gap),
                  camBtn(),
                  const SizedBox(width: gap),
                  Expanded(child: SizedBox(height: rowHeight, child: GlassPrimaryButton(label: 'Next', onTap: onNext))),
                ],
              )
            : SizedBox(key: const ValueKey('single_next'), height: rowHeight, width: double.infinity, child: GlassPrimaryButton(label: 'Next', onTap: onNext)),
      ),
    );
  }
}
