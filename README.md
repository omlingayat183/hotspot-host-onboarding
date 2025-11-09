# Hotspot Host Onboarding (Flutter)

A polished onboarding questionnaire for hotspot hosts with text input, audio recording, and video capture — built with Flutter and Riverpod.

## ✨ Features Implemented
- Onboarding UI with progress and glassmorphism styling
- Text answer with max length and focus styling
- Audio recording (AAC) using `record` + waveform UI (`audio_waveforms`)
- Video recording with front camera via `camera` + preview via `video_player`
- State management with Riverpod
- Responsive bottom action row with dynamic buttons (Mic/Camera/Next)
- Deletion flows for audio/video with safe file handling

## 🍫 Brownie Points (Extras)
- Animated faux waveform while recording/playing
- Glass-styled primary/secondary buttons with shadows and gradients
- Defensive file deletion (rename-then-delete fallback)
- Timer ticker and mm:ss formatting
- Smooth `AnimatedSize` / `AnimatedSwitcher` transitions in the bottom bar

## ➕ Additional Enhancements
- Tight permission checks (`permission_handler`)
- Robust UI states (recording, media present, disabled states)
- Clean separation (`AudioRecordedCard`, shared UI components)

## 🧪 How to Run
```bash
flutter pub get
flutter run
