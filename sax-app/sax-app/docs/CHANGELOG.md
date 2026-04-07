# Changelog

All notable changes to the Blue Note Tuner project will be documented in this file.

## [2026-04-07] Phase 15: Sheet Music Sight Reading
- **Staff Engine**: Developed a custom `StaffView` to dynamically render a 5-line musical staff, treble clef, and ledger lines based on pitch height.
- **Game Logic**: Built a 60-second "Call & Response" game loop that prompts random notes within the saxophone's written range (C4-C6).
- **High Scores**: Integrated persistent high score tracking via `UserDefaults`.
- **Response Optimization**: Lowered amplitude thresholds (`0.05`) and stability requirements (`3 frames`) to ensure snappy performance on instruments with fast decay like the piano.

## [2026-04-07] Phase 14: Intonation Tendency Analytics
- **Visual Analytics**: Implemented a professional bar chart using SwiftUI `Charts` to visualize sharp/flat tendencies per pitch.
- **Drill Architecture**: Refactored to an "Active Drill" model (Option A) with an explicit Start/Stop session toggle.
- **Session Tracking**: Added a live session timer and a pulsing "Recording" indicator for clear UX feedback.
- **Persistence**: Statistics now persist across app launches, allowing long-term tracking of instrument quirks.

## [2026-04-07] Metronome & UX Refinements
- **Manual Tempo Input**: Added a hidden feature to tap the center BPM display to trigger a numeric keypad alert for 1:1 tempo jumps.
- **AudioKit Cleanup**: Resolved compiler warnings regarding `AudioEngine.isRunning` and optimized audio session activation logic.

## [2026-04-07] Phase 13: Unforgiving Metronome (Refactored)
- Engineered a high-precision metronome utilizing `DispatchSourceTimer` on a `.userInteractive` background thread to guarantee 0% jitter.
- Refactored audio from `AVAudioEngine` to in-memory `AVAudioPlayer` to prevent audio session conflicts with the Tuner and Drone.
- Developed `MetronomeView` featuring a clean 4-beat visual indicator, animated BPM numbers, and synced screen flashes.

## [2026-04-07] Bug Fixes & Design Upgrades
- **App Icon**: Designed a premium, full-bleed "Blue Note" app icon featuring an "Eb" motif in modern jazz typography.
- **Icon Configuration**: Fixed Xcode asset management issues by correctly configuring `AppIcon.appiconset` for universal 1024x1024 support.
- **Long Tone Tuning**: Implemented a 0.3s "Grace Period" and lowered amplitude thresholds to support decaying instruments like pianos and softer saxophone saxophones.

## [2026-04-07] Phase 12: Drone Pitch Generator
- Built a vintage analog synth Drone Generator using SoundpipeAudioKit (`Oscillator` + `LowPassFilter`).
- Transposition logic automatically converts the selected "Written" pitch to the correct "Sounding" concert pitch based on the global instrument setting.
- Created `DroneView` featuring a massive, tactile interface and smooth oscillator ramping.

## [2026-04-07] Phase 11: Long Tone Endurance Test
- Created `LongToneView` to track embouchure stamina and pitch stability.
- Implemented an unforgiving 0.1s resolution timer that instantly resets upon intonation failure.
- Built a visual "pressure gauge" that scales color from Cyan to Red over 30 seconds.
- Integrated dynamic Fletcher insults based on the specific type of failure (dropped pitch, stopped playing, going sharp/flat).

## [2026-04-07] Phase 10: App Navigation & Architecture Restructuring
- Transitioned application root from `ContentView` to a new `MainView` utilizing `NavigationSplitView` for an expandable sidebar.
- Abstracted `Instrument` and `TuningMode` state into a globally accessible `AppSettings` object.
- Persisted user settings using `@AppStorage` (UserDefaults) so preferences remain between app sessions.
- Cleaned up the primary Tuner UI by decoupling the settings controls into a beautiful, dedicated `SettingsView`.

## [2026-04-06] Phase 7: UI Visualization Upgrade
- Added tick marks, +/- 50 labels, and a dedicated "In-Tune" tolerance zone to the gauge.
- Redesigned the moving indicator to be more prominent and easily readable.

## [2026-04-06] Phase 8: Control Responsibility
- Replaced the unresponsive `Menu` dropdowns with high-precision "Pill-style" segmented buttons.
- Implemented tactile feedback and large tap targets for professional use.

## [2026-04-06] Phase 9: Permission & Lifecycle
- Modernized the code to handle **iOS 17+** `AVAudioApplication` permission requests.
- Updated lifecycle management (`onChange`) to satisfy the latest SwiftUI deprecation warnings.
- Established a professional `.gitignore` to keep the repository clean of Xcode junk data.
