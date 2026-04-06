# Blue Note Tuner

Instrument tuner for alto sax (+ potentially more if I can be arsed) for ios/Ipad. Feedback courtesy of JK Simmons character from Whiplash lmao

## Key Features

- **Low Latency**: Real-time pitch detection using the YIN algorithm.
- **Transposition Support**: Built-in offsets for Concert, Alto Sax, Tenor Sax, and Trumpet.
- **Fletcher Mode**: Fully ruthless feedback from JK Simmons character from Whiplash.

## Tech Stack

- **Language**: Swift
- **Framework**: SwiftUI
- **Audio DSP**:
  - [AudioKit](https://github.com/AudioKit/AudioKit)
  - [SoundpipeAudioKit](https://github.com/AudioKit/SoundpipeAudioKit)
- **Architecture**: MVVM (Model-View-ViewModel)

## Requirements

- **Hardware**: Physical iOS/iPadOS device recommended for microphone input.
- **Microphone**: Requires microphone permissions (`NSMicrophoneUsageDescription`).
- **Dependencies**: Managed via Swift Package Manager (SPM).
