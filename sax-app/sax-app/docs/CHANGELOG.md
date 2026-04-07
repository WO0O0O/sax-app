# Changelog

All notable changes to the Blue Note Tuner project will be documented in this file.

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
