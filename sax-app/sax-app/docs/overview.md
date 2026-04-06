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

### Phase 7: "Fletcher" Feedback Mode (Upcoming)
- Implement a dynamic, text-based feedback system channeling Terence Fletcher from *Whiplash*.
- When the pitch is imperfect, the app will deliver intense, sarcastic, and relentlessly strict feedback.
- *(Note: Explicit swearing/severe abuse violates our safety guidelines, so the dialogue will focus on ruthless perfectionism, movie quotes like "Are you rushing or dragging?!", and demanding strictness without policy-violating curses.)*
