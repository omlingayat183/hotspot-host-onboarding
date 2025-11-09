# Hotspot Host Onboarding – Flutter Assignment

A complete onboarding questionnaire flow for Hotspot Hosts, including text input, audio recording, video recording, waveform UI, and Riverpod state management.

---

## ✅ Features Implemented
- Onboarding screen with progress indicator  
- Glassmorphism-styled UI components  
- Text input with live character count and max length  
- Audio recording using `record`  
- Live waveform visualization using `audio_waveforms`  
- Audio playback using `just_audio`  
- Video recording using `camera`  
- Video preview using `video_player`  
- State management with Riverpod  
- Bottom action bar with Mic / Camera / Next buttons  
- Responsive layout + smooth transitions (`AnimatedSize`, `AnimatedSwitcher`)

---

## 🍫 Brownie Points (Extras)
- Animated waveform while playing/recording  
- Safe file deletion (rename fallback)  
- Defensive checks for file existence  
- Custom glass buttons + gradients + shadows  
- mm:ss timer with ticker  
- Permission handling for mic/camera  
- Expansion/collapse animations in action bar  

---

## ➕ Additional Enhancements
- Robust UI states (active/inactive/recording/disabled)  
- Unified design system with `Fx` styles  
- Consistent border radius & spacing system  
- Error-safe audio player disposal  
- Clean separation of widgets (`AudioRecordedCard`, shared widgets)

---

## 🛠 Permissions Required

### **Android**
Declare in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
iOS
Add to ios/Runner/Info.plist:

xml
Copy code
<key>NSMicrophoneUsageDescription</key>
<string>This app requires microphone access for audio recording.</string>

<key>NSCameraUsageDescription</key>
<string>This app uses the camera for video recording.</string>
📦 Packages Used
csharp
Copy code
flutter_riverpod
record
audio_waveforms
camera
video_player
just_audio
permission_handler
path_provider
📹 Demo
Screen Recording:
<ADD_DRIVE_OR_YOUTUBE_LINK_HERE>

(Optional GIF):
docs/demo.gif

📁 Project Structure (Key Parts)
markdown
Copy code
lib/
  features/
    onboarding/
      onboarding_question_screen.dart
    experience/
      widgets/
        audio_recorded_card.dart
        shared_ui_widgets.dart
  state/
    onboarding_providers.dart
🧹 Notes
Audio deletion is handled in
onboarding_question_screen.dart → _deleteAudio()

AudioRecordedCard triggers deletion through its onDelete callback.

Video deletion is handled similarly via _deleteVideo()

▶️ Run the Project
bash
Copy code
flutter pub get
flutter run
