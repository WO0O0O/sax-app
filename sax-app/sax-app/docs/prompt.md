Role: You are an expert iOS Developer, SwiftUI architect, and Audio DSP engineer. Your task is to autonomously build a real-time iOS/iPadOS Tuner application from scratch using Swift, SwiftUI, and AudioKit.

Project Overview:
I am building a highly responsive, low-latency instrument tuner primarily designed for saxophone players, but architected to support multiple transpositions. The app must feature a distinct "Blue Note Records" jazz aesthetic—avoiding technical clinical looks in favor of bold, asymmetrical typography, deep blues, cream colors, and stylish visual feedback.

Tech Stack & Dependencies:

Language/Framework: Swift, SwiftUI

Architecture: MVVM (Model-View-ViewModel)

Audio DSP: AudioKit and SoundpipeAudioKit (via Swift Package Manager). URLs: https://github.com/AudioKit/AudioKit and https://github.com/AudioKit/SoundpipeAudioKit

Design System (The "Blue Note" Aesthetic):

Colors: Deep Navy background (e.g., #0A1128), Cream/Off-White text (#F2EFE9), and a striking accent color for "In Tune" (e.g., a vibrant vintage Cyan or Orange).

Typography: Use heavy, bold, sans-serif system fonts for the note display. Embrace asymmetry (e.g., off-center note displays, dynamic font weights).

Visualizer: Instead of a traditional clinical needle, build a dynamic, minimalist graphic (like a shifting bar or an abstract shape) that cleanly indicates flat/sharp. It should be easily readable out of the corner of the user's eye while playing.

Phase 1: Configuration & Dependencies
Permissions: Update the Info.plist with the NSMicrophoneUsageDescription key. The string should be: "Required to hear your instrument and track pitch."

SPM: Add AudioKit and SoundpipeAudioKit to the Xcode project dependencies.

Phase 2: Data Models (Scalability)
Create a file named TuningModels.swift.

Instrument Enum: Create an enum for Instrument. It should have cases for .concert (0 semitone offset) and .altoSax (+9 semitone offset). Do not hardcode Eb into the main engine; use this enum to calculate the offset so we can easily add .tenorSax or .trumpet later.

TuningMode Enum: Create an enum for TuningMode with cases for .casual (tolerance of +/- 12 cents) and .pro (tolerance of +/- 5 cents).

Phase 3: The Audio Engine (ViewModel)
Create a file named TunerConductor.swift (using @Observable or ObservableObject).

Setup: Configure the AVAudioSession for .playAndRecord and .measurement to bypass Apple's voice noise-cancellation.

AudioKit Routing: Initialize an AudioEngine. Route the microphone input into a PitchTap node (which uses the YIN algorithm).

Math & Logic:

Pull the frequency (Hz) and amplitude from PitchTap.

Implement a volume gate: if the amplitude is too low, ignore the pitch to prevent erratic UI jumping from background noise.

Convert the frequency to a MIDI note using standard logarithmic math.

Apply the semitone offset based on the selected Instrument enum.

Calculate the exact cents deviation from the perfect mathematical pitch of that note.

Published Properties: Expose the currently detected note name (String), the cents deviation (Double), the active Instrument, and the active TuningMode to the view.

Phase 4: UI Implementation
Create the main interface in ContentView.swift.

Header: Create a stylish, asymmetrical header. Include two simple toggle buttons or pickers: one to switch between "Concert" and "Alto Sax", and another to switch between "Casual" and "Pro" modes.

Note Display: The central focus should be the Note Name. Make it massive and bold.

Tuning Indicator: Build a custom SwiftUI view that uses the cents variable to show pitch accuracy. Tie the "In Tune" visual state to the active TuningMode tolerance. When the pitch falls within the tolerance window, trigger a smooth, satisfying color change and scale animation to reward the user.

Lifecycle Management: Ensure the AudioEngine starts when the view appears and properly pauses/stops when the app goes into the background using the scenePhase environment variable.

Execution Rules: Ensure the code is production-ready, handles optionals safely, and avoids forced unwraps where possible. Write the code cleanly and provide the complete file contents so I can drop them straight into my project.
