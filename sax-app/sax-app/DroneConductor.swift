import Foundation
import Combine
import AudioKit
import SoundpipeAudioKit
import AVFoundation

class DroneConductor: ObservableObject {
    let engine = AudioEngine()
    var oscillator: Oscillator
    var filter: LowPassFilter!
    
    @Published var isPlaying = false
    @Published var volume: AUValue = 0.5 {
        didSet {
            oscillator.amplitude = volume * 0.4 // Overall master cap to prevent blowing speakers
        }
    }
    
    init() {
        // Build the audio chain
        oscillator = Oscillator(waveform: Table(.sawtooth))
        oscillator.amplitude = volume * 0.4
        
        filter = LowPassFilter(oscillator)
        filter.cutoffFrequency = 600 // Warm synth gritty sound
        filter.resonance = 0.1
        
        engine.output = filter
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure drone audio session: \(error.localizedDescription)")
        }
    }
    
    func setPitch(noteIndex: Int, instrument: Instrument) {
        // We use Octave 3 as the base written drone (MIDI note 48 = C3)
        // If user selects "C", noteIndex is 0 -> 48
        let writtenMidi = 48 + noteIndex
        
        // Subtract the offset to convert from Written pitch back to Concert (Sounding) pitch for the oscillator
        let soundingMidi = writtenMidi - instrument.semitoneOffset
        
        // Convert standard MIDI to Hz for the oscillator to play
        let hz = 440.0 * pow(2.0, Double(soundingMidi - 69) / 12.0)
        
        // Smooth scaling of frequency to prevent loud clicking when changing notes
        oscillator.$frequency.ramp(to: AUValue(hz), duration: 0.1)
    }
    
    func start() {
        do {
            try engine.start()
            oscillator.start()
            isPlaying = true
        } catch {
            print("Failed to start Drone AudioEngine")
        }
    }
    
    func stop() {
        oscillator.stop()
        engine.stop()
        isPlaying = false
    }
}
