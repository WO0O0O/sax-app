# Blue Note Tuner: Project Overview & Plan

This document outlines the project goals and our step-by-step implementation plan for building a highly responsive, low-latency instrument tuner with a "Blue Note Records" aesthetic.

## Development Workflow
**Note:** Antigravity (the AI) will act as the architect and write the code here in this folder. Since this is an iOS app, the user will need to open or paste these files into **Xcode** to actually build, run, and view the app on an iPhone or Simulator. 

*We will build the files here, and you should paste them into Xcode as we go along (or drag the generated files into your Xcode Project).*

## Phases

### Phase 1: Planning and Setup (Complete)
- Define architecture: MVVM with `TuningModels`, `TunerConductor` (ViewModel), and `ContentView` (View).
- Define "Blue Note" aesthetic: Navy, Cream, Cyan/Orange accents, bold/asymmetrical typography.

### Phase 2: Configuration & Dependencies (Pending Xcode Download)
- Create a new iOS SwiftUI App in Xcode.
- Add AudioKit and SoundpipeAudioKit via Swift Package Manager to the Xcode project.
- Update `Info.plist` with `Privacy - Microphone Usage Description`.

### Phase 3: Data Models (Complete)
- **`TuningModels.swift`**: Contains `Instrument` and `TuningMode` enums to handle transposition (e.g., Alto Sax) and UI state.

### Phase 4: The Audio Engine (ViewModel) (In Progress)
- **`TunerConductor.swift`**: Sets up `AVAudioSession`, routes the mic to a `PitchTap` node (YIN algorithm), and performs the mathematical conversions (Hz to MIDI, Volume Gating, Cents Deviation).

### Phase 5: UI Implementation
- **`ContentView.swift`**: The main interface combining the components, featuring massive bold text for the note name and dynamic abstract graphics using the cents variable to show pitch accuracy.

### Phase 6: Expansion & Assets (Complete)
- **`BlueNoteTunerApp.swift`**: Application entry point.
- **`TuningModels.swift`**: Expanded to include Tenor Sax and Trumpet transpositions.
- **Design**: Generated premium Blue Note App Icon.

### Phase 7: "Fletcher" Feedback Mode (Complete)
- Implement a dynamic, text-based feedback system channeling Terence Fletcher from *Whiplash*.
- When the pitch is imperfect, the app will deliver intense, sarcastic, and relentlessly strict feedback.

### Phase 8: UI Visualization Upgrade (Complete)
- Added tick marks, +/- 50 labels, and a dedicated "In-Tune" tolerance zone to the gauge.
- Redesigned the moving indicator.

### Phase 9: Control Responsibility & Lifecycle (Complete)
- Replaced the unresponsive Menu dropdowns with "Pill-style" segmented buttons.
- Modernized iOS 17+ AVAudioApplication permissions and lifecycle management.

### Phase 10: App Navigation & Architecture Restructuring (Upcoming)
- Introduce a left-side Sidebar navigation (using `NavigationSplitView`) to manage multiple tools under one app, keeping the interface clean and professional.
- Clean up the Start Page: Only the main "Tone Checker" and its Fletcher feedback remain.
- Create a dedicated "Settings" Screen: Move the "Casual/Pro" difficulty and "Instrument" options (Alto, Tenor, Concert/Piano, Trumpet, etc.) off the main screen into here.

### Phase 11: Long Tone Endurance Test (Upcoming)
- A new dedicated screen for long tones.
- Starts a timer when playing begins. Timer resets if pitch drifts outside of tolerance (set by Casual/Pro mode).
- Visual "heat" or "pressure" bar to reward endurance.

### Phase 12: Drone Pitch Generator (Upcoming)
- A new screen for drone practice to develop your ear.
- Uses AudioKit oscillator to play a continuous, vintage analog synth drone on a selected root note.

### Phase 13: Unforgiving Metronome (Upcoming)
- A beautifully designed metronome screen with Tap tempo, visual flash, and subdivisions.
- Ties into the "Fletcher" theme: throws insults if you stop playing or drift off-tempo.

### Phase 14: Intonation Tendency Analytics (Complete)
- Professional dashboard featuring SwiftUI `Charts` for real-time visualization of pitch trends.
- Active "Analytics Drill" mode with manual Start/Stop, session timer, and recording indicator.
- Persistent data storage via `UserDefaults`.

### Phase 15: Sheet Music "Call & Response" Practice (Complete)
- Custom musical staff rendering engine with Treble Clef and Ledger lines.
- 60-second gamified drill targeting notes tailored for the Alto Saxophone range.
- High Score persistence and sensitivity optimization for piano (lower amp thresholds).
