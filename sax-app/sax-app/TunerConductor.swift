import Foundation
import Combine
import AudioKit
import SoundpipeAudioKit
import AVFoundation

class TunerConductor: ObservableObject {
    @Published var data = TunerState()
    @Published var instrument: Instrument = .altoSax
    @Published var mode: TuningMode = .casual
    @Published var currentInsult: String = "NOT QUITE MY TEMPO."

    let engine = AudioEngine()
    var mic: AudioEngine.InputNode?
    var tracker: PitchTap?
    // A silencer so we don't output the mic to the speakers, causing feedback
    var silence: Mixer?

    let noteNamesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    init() {
        setupAudioSession()
        setupEngine()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // .measurement is important to bypass Apple's voice noise-cancellation
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.mixWithOthers])
            try session.setActive(true)
            
            // Request microphone permission (Modern iOS 17+ check with fallback)
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    print(granted ? "Microphone access granted." : "Microphone access denied.")
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    print(granted ? "Microphone access granted." : "Microphone access denied.")
                }
            }
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    private func setupEngine() {
        guard let input = engine.input else {
            print("Could not find AudioEngine input.")
            return
        }
        mic = input
        silence = Mixer(input)
        silence?.volume = 0.0
        engine.output = silence

        // YIN algorithm via PitchTap
        tracker = PitchTap(input) { [weak self] pitch, amp in
            DispatchQueue.main.async {
                self?.update(pitch: pitch[0], amp: amp[0])
            }
        }
    }

    func start() {
        do {
            try engine.start()
            tracker?.start()
            data.isRecording = true
        } catch {
            print("Failed to start AudioEngine: \(error.localizedDescription)")
        }
    }

    func stop() {
        tracker?.stop()
        engine.stop()
        data.isRecording = false
    }

    private func update(pitch: AUValue, amp: AUValue) {
        // Volume gate: ignore ambient background noise if the amp is less than 0.05
        data.amplitude = amp
        guard amp > 0.05 else {
            return
        }

        // Convert Hz to standard MIDI Note (using A440 tuning)
        let frequency = Double(pitch)
        if frequency < 20 || frequency > 4000 { return } // Out of bounds for standard instruments

        // MIDI Pitch Calculation: A4=440Hz -> MIDI 69
        let midiFloat = 69.0 + 12.0 * log2(frequency / 440.0)
        
        // Exact mathematical note
        let midiNote = Int(round(midiFloat))
        let cents = (midiFloat - Double(midiNote)) * 100.0

        // Apply Transposition Offset based on the selected instrument
        let transposedMidi = midiNote + instrument.semitoneOffset
        
        let pitchClass = transposedMidi % 12
        var normalizedPitchClass = pitchClass
        while normalizedPitchClass < 0 {
            normalizedPitchClass += 12
        }

        data.cents = cents
        data.noteName = noteNamesWithSharps[normalizedPitchClass]

        let inTune = data.isInTune(for: mode)
        // Only update the insult 1/50th of the frames so it doesn't flicker wildly
        if Int.random(in: 0...50) == 1 {
             currentInsult = FletcherFeedback.getInsult(cents: data.cents, isInTune: inTune)
        }
    }
}
