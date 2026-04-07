import Foundation
import Combine
import AudioKit
import SoundpipeAudioKit
import AVFoundation

class StatsConductor: ObservableObject {
    @Published var isTracking: Bool = false
    @Published var recordedStats: [NoteStatistic] = []
    @Published var currentCentsForUI: Double = 0.0
    @Published var currentNoteForUI: String = "--"
    
    let engine = AudioEngine()
    var mic: AudioEngine.InputNode?
    var tracker: PitchTap?
    var silence: Mixer?
    
    weak var settings: AppSettings?
    
    let noteNamesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    private let statsKey = "blueNoteStats"
    
    // Limits tracking so we don't skew data by registering every single millisecond frame
    // We'll process a reading roughly every 5 frames if stable
    private var readingCounter = 0
    
    @Published var sessionTime: Int = 0
    private var sessionTimer: Timer?
    
    init() {
        loadStats()
        setupAudioSession()
        setupEngine()
    }
    
    private func loadStats() {
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let savedStats = try? JSONDecoder().decode([NoteStatistic].self, from: data) {
            self.recordedStats = savedStats
        }
    }
    
    private func saveStats() {
        if let encoded = try? JSONEncoder().encode(recordedStats) {
            UserDefaults.standard.set(encoded, forKey: statsKey)
        }
    }
    
    func resetStats() {
        recordedStats = []
        saveStats()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("StatsConductor Audio Session error: \(error.localizedDescription)")
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
                self.update(pitch: pitch[0], amp: amp[0], instrument: settings.instrument)
            }
        }
    }
    
    func toggleTracking() {
        if isTracking {
            stopTracking()
        } else {
            startTracking()
        }
    }
    
    func startTracking() {
        guard !isTracking else { return }
        do {
            try engine.start()
            tracker?.start()
            isTracking = true
            sessionTime = 0
            sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.sessionTime += 1
            }
        } catch {
            print("Failed to start AudioEngine: \(error.localizedDescription)")
        }
    }
    
    func stopTracking() {
        guard isTracking else { return }
        tracker?.stop()
        engine.stop()
        sessionTimer?.invalidate()
        sessionTimer = nil
        isTracking = false
        currentNoteForUI = "--"
        currentCentsForUI = 0.0
    }
    
    private func update(pitch: AUValue, amp: AUValue, instrument: Instrument) {
        guard isTracking, amp > 0.08 else {
            currentNoteForUI = "--"
            return
        }

        let frequency = Double(pitch)
        if frequency < 20 || frequency > 4000 { return }

        let midiFloat = 69.0 + 12.0 * log2(frequency / 440.0)
        let midiNote = Int(round(midiFloat))
        let cents = (midiFloat - Double(midiNote)) * 100.0
        
        let transposedMidi = midiNote + instrument.semitoneOffset
        let pitchClass = transposedMidi % 12
        var normalizedPitchClass = pitchClass
        while normalizedPitchClass < 0 {
            normalizedPitchClass += 12
        }
        
        let noteName = noteNamesWithSharps[normalizedPitchClass]
        
        currentNoteForUI = noteName
        currentCentsForUI = cents
        
        readingCounter += 1
        if readingCounter >= 5 {
            readingCounter = 0
            recordReading(noteName: noteName, cents: cents)
        }
    }
    
    private func recordReading(noteName: String, cents: Double) {
        if let index = recordedStats.firstIndex(where: { $0.noteName == noteName }) {
            recordedStats[index].addReading(cents: cents)
        } else {
            let newStat = NoteStatistic(noteName: noteName, playCount: 1, averageCentsDeviation: cents)
            recordedStats.append(newStat)
            recordedStats.sort { $0.noteName < $1.noteName }
        }
        saveStats()
    }
}
