import 'package:flutter_riverpod/legacy.dart';

class OnboardingQState {
  final String longAnswer; 
  final String? audioPath;
  final String? videoPath;
  final bool isRecordingAudio;
  const OnboardingQState({
    this.longAnswer = '',
    this.audioPath,
    this.videoPath,
    this.isRecordingAudio = false,
  });

  OnboardingQState copyWith({
    String? longAnswer,
    String? audioPath,
    String? videoPath,
    bool? isRecordingAudio,
  }) => OnboardingQState(
    longAnswer: longAnswer ?? this.longAnswer,
    audioPath: audioPath ?? this.audioPath,
    videoPath: videoPath ?? this.videoPath,
    isRecordingAudio: isRecordingAudio ?? this.isRecordingAudio,
  );
}

class OnboardingQNotifier extends StateNotifier<OnboardingQState> {
  OnboardingQNotifier() : super(const OnboardingQState());

  void setAnswer(String v) => state = state.copyWith(longAnswer: v);
  void setAudio(String? path) => state = state.copyWith(audioPath: path);
  void setVideo(String? path) => state = state.copyWith(videoPath: path);
  void setRecording(bool v) => state = state.copyWith(isRecordingAudio: v);
  void reset() => state = const OnboardingQState();
}

final onboardingQProvider =
    StateNotifierProvider<OnboardingQNotifier, OnboardingQState>(
        (ref) => OnboardingQNotifier());
