import Foundation
import Combine
import AudioKit
import SoundpipeAudioKit
import AVFoundation

enum SightReadingGameState {
    case waitingToStart
    case playing
    case gameOver
}

class SightReadingConductor: ObservableObject {
    @Published var currentPrompt: SightReadingPrompt?
    @Published var gameState: SightReadingGameState = .waitingToStart
    @Published var score: Int = 0
    @Published var timeRemaining: Int = 60
    @Published var feedbackMessage: String = "Play the note to begin."
    
    // UI state for the current pitch being played
    @Published var currentNoteForUI: String = "--"
    @Published var currentCentsForUI: Double = 0.0
    
    let engine = AudioEngine()
    var mic: AudioEngine.InputNode?
    var tracker: PitchTap?
    var silence: Mixer?
    
    weak var settings: AppSettings?
    
    let noteNamesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    private var timer: Timer?
    private var successHoldCounter: Int = 0
    
    // We restrict this specifically to Alto Sax range.
    // C4 (Middle C) is our base (staffPosition 0).
    let possiblePrompts: [SightReadingPrompt] = [
        SightReadingPrompt(writtenNoteName: "C", octave: 4, staffPosition: 0),
        SightReadingPrompt(writtenNoteName: "D", octave: 4, staffPosition: 1),
        SightReadingPrompt(writtenNoteName: "E", octave: 4, staffPosition: 2),
        SightReadingPrompt(writtenNoteName: "F", octave: 4, staffPosition: 3),
        SightReadingPrompt(writtenNoteName: "G", octave: 4, staffPosition: 4),
        SightReadingPrompt(writtenNoteName: "A", octave: 4, staffPosition: 5),
        SightReadingPrompt(writtenNoteName: "B", octave: 4, staffPosition: 6),
        SightReadingPrompt(writtenNoteName: "C", octave: 5, staffPosition: 7),
        SightReadingPrompt(writtenNoteName: "D", octave: 5, staffPosition: 8),
        SightReadingPrompt(writtenNoteName: "E", octave: 5, staffPosition: 9),
        SightReadingPrompt(writtenNoteName: "F", octave: 5, staffPosition: 10),
        SightReadingPrompt(writtenNoteName: "G", octave: 5, staffPosition: 11),
        SightReadingPrompt(writtenNoteName: "A", octave: 5, staffPosition: 12),
        SightReadingPrompt(writtenNoteName: "B", octave: 5, staffPosition: 13),
        SightReadingPrompt(writtenNoteName: "C", octave: 6, staffPosition: 14)
    ]
    
    init() {
        setupAudioSession()
        setupEngine()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("SightReadingConductor Audio Session error: \(error.localizedDescription)")
        }
    }
    
    private func setupEngine() {
        guard let input = engine.input else { return }
        mic = input
        silence = Mixer(input)
        silence?.volume = 0.0
        engine.output = silence

        tracker = PitchTap(input) { [weak self] pitch, amp in
            DispatchQueue.main.async {
                guard let self = self, let settings = self.settings else { return }
                self.update(pitch: pitch[0], amp: amp[0], instrument: settings.instrument, mode: settings.mode)
            }
        }
    }
    
    func startGame() {
        score = 0
        timeRemaining = 60
        gameState = .playing
        feedbackMessage = "Read the staff!"
        generateNextPrompt()
        
        do {
            try engine.start()
            tracker?.start()
        } catch {
            print("Failed to start AudioEngine: \(error.localizedDescription)")
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endGame()
            }
        }
    }
    
    @Published var highScore: Int = UserDefaults.standard.integer(forKey: "sightReadingHighScore")

    func endGame() {
        gameState = .gameOver
        tracker?.stop()
        engine.stop()
        timer?.invalidate()
        timer = nil
        feedbackMessage = "Time's Up! Score: \(score)"
        
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "sightReadingHighScore")
            feedbackMessage = "NEW RECORD: \(score)!"
        }
        
        currentPrompt = nil
        currentNoteForUI = "--"
    }
    
    func stop() {
        tracker?.stop()
        engine.stop()
        timer?.invalidate()
        timer = nil
    }
    
    private func generateNextPrompt() {
        currentPrompt = possiblePrompts.randomElement()
        successHoldCounter = 0
    }
    
    private func update(pitch: AUValue, amp: AUValue, instrument: Instrument, mode: TuningMode) {
        // Lowered amp threshold to 0.05 to better catch decaying piano notes
        guard gameState == .playing, amp > 0.05 else {
            currentNoteForUI = "--"
            return
        }

        let frequency = Double(pitch)
        if frequency < 20 || frequency > 4000 { return }

        let midiFloat = 69.0 + 12.0 * log2(frequency / 440.0)
        let midiNote = Int(round(midiFloat))
        let cents = (midiFloat - Double(midiNote)) * 100.0
        
        // Calculate written pitch
        let transposedMidi = midiNote + instrument.semitoneOffset
        let pitchClass = transposedMidi % 12
        var normalizedPitchClass = pitchClass
        while normalizedPitchClass < 0 {
            normalizedPitchClass += 12
        }
        
        let octave = (transposedMidi / 12) - 1
        let noteName = noteNamesWithSharps[normalizedPitchClass]
        
        currentNoteForUI = "\(noteName)\(octave)"
        currentCentsForUI = cents
        
        // Check game logic
        guard let prompt = currentPrompt else { return }
        
        let isRightPitch = noteName == prompt.writtenNoteName && octave == prompt.octave
        let isInTune = abs(cents) <= mode.tolerance
        
        if isRightPitch && isInTune {
            successHoldCounter += 1
            // Lowered hold counter from 5 to 3 making it punchier and more responsive to staccato or piano attacks
            if successHoldCounter >= 3 {
                score += 1
                feedbackMessage = ["NICE.", "GOOD.", "NEXT.", "KEEP GOING.", "NAILED IT."].randomElement()!
                generateNextPrompt()
            } else {
                feedbackMessage = "HOLD IT..."
            }
        } else if isRightPitch && !isInTune {
            successHoldCounter = 0
            feedbackMessage = "YOU'RE \(cents > 0 ? "SHARP" : "FLAT")!"
        } else {
            successHoldCounter = 0
        }
    }
}
