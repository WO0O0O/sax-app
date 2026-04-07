import Foundation
import AVFoundation
import Combine

class MetronomeConductor: ObservableObject {
    @Published var bpm: Double = 120.0
    @Published var isPlaying = false
    @Published var beatFlash = false
    @Published var currentBeat = 1 // 1-4
    
    let timeSignature = 4
    private var tapTimes: [Date] = []
    
    private var timer: DispatchSourceTimer?
    private var downbeatPlayer: AVAudioPlayer?
    private var upbeatPlayer: AVAudioPlayer?

    init() {
        buildClickPlayers()
    }
    
    private func buildClickPlayers() {
        downbeatPlayer = makeClickPlayer(frequency: 1800, amplitude: 0.9)
        upbeatPlayer = makeClickPlayer(frequency: 900, amplitude: 0.6)
    }
    
    /// Synthesize a click sound entirely in memory – no audio files needed.
    private func makeClickPlayer(frequency: Double, amplitude: Double) -> AVAudioPlayer? {
        let sampleRate: Double = 44100
        let duration: Double = 0.04 // 40ms is a tight, sharp click
        let frameCount = Int(sampleRate * duration)
        
        var samples = [Int16]()
        samples.reserveCapacity(frameCount)
        
        for i in 0..<frameCount {
            let decay = pow(1.0 - Double(i) / Double(frameCount), 3.0)
            let wave = sin(2.0 * .pi * frequency * Double(i) / sampleRate)
            let value = wave * decay * amplitude * Double(Int16.max)
            samples.append(Int16(clamping: Int(value)))
        }
        
        // Build a minimal WAV file in memory
        var wavData = Data()
        
        let dataSize = UInt32(frameCount * 2)  // 16-bit mono
        let sampleRateInt = UInt32(sampleRate)
        let byteRate: UInt32 = sampleRateInt * 2
        let totalSize: UInt32 = 36 + dataSize
        
        // RIFF header
        wavData.append(contentsOf: "RIFF".utf8)
        wavData.append(contentsOf: withUnsafeBytes(of: totalSize.littleEndian) { Array($0) })
        wavData.append(contentsOf: "WAVE".utf8)
        // fmt  chunk
        wavData.append(contentsOf: "fmt ".utf8)
        wavData.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Array($0) }) // chunk size
        wavData.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) })  // PCM
        wavData.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) })  // channels
        wavData.append(contentsOf: withUnsafeBytes(of: sampleRateInt.littleEndian) { Array($0) })
        wavData.append(contentsOf: withUnsafeBytes(of: byteRate.littleEndian) { Array($0) })
        wavData.append(contentsOf: withUnsafeBytes(of: UInt16(2).littleEndian) { Array($0) })  // block align
        wavData.append(contentsOf: withUnsafeBytes(of: UInt16(16).littleEndian) { Array($0) }) // bits per sample
        // data chunk
        wavData.append(contentsOf: "data".utf8)
        wavData.append(contentsOf: withUnsafeBytes(of: dataSize.littleEndian) { Array($0) })
        
        for sample in samples {
            wavData.append(contentsOf: withUnsafeBytes(of: sample.littleEndian) { Array($0) })
        }
        
        return try? AVAudioPlayer(data: wavData)
    }

    func start() {
        guard !isPlaying else { return }
        isPlaying = true
        currentBeat = 1
        scheduleTimer()
    }
    
    private func scheduleTimer() {
        timer?.cancel()
        
        let intervalNanos = UInt64(60_000_000_000 / bpm) // nanoseconds per beat
        let newTimer = DispatchSource.makeTimerSource(flags: .strict, queue: DispatchQueue.global(qos: .userInteractive))
        newTimer.schedule(deadline: .now(), repeating: .nanoseconds(Int(intervalNanos)), leeway: .nanoseconds(1000))
        newTimer.setEventHandler { [weak self] in
            self?.tick()
        }
        newTimer.resume()
        timer = newTimer
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
        isPlaying = false
        currentBeat = 1
    }

    private func tick() {
        let beat = currentBeat
        let isDownbeat = beat == 1
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.beatFlash = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.beatFlash = false
            }
            self.currentBeat = (self.currentBeat % self.timeSignature) + 1
        }
        
        if isDownbeat {
            downbeatPlayer?.currentTime = 0
            downbeatPlayer?.play()
        } else {
            upbeatPlayer?.currentTime = 0
            upbeatPlayer?.play()
        }
    }
    
    func tapTempo() {
        let now = Date()
        tapTimes.append(now)
        tapTimes.removeAll { now.timeIntervalSince($0) > 4.0 }
        
        guard tapTimes.count >= 2 else { return }
        
        let intervals = zip(tapTimes.dropFirst(), tapTimes).map { $0.timeIntervalSince($1) }
        let avg = intervals.reduce(0, +) / Double(intervals.count)
        let calculated = (60.0 / avg).rounded()
        
        if (40...300).contains(calculated) {
            bpm = calculated
            if isPlaying {
                stop()
                start()
            }
        }
    }
}
