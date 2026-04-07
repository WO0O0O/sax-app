import SwiftUI
import Combine

struct LongToneView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var conductor = TunerConductor()
    
    @State private var currentDuration: TimeInterval = 0.0
    @State private var bestDuration: TimeInterval = 0.0
    @State private var failMessage: String = "PLAY A NOTE AND HOLD IT."
    
    @State private var consecutiveFailures: Int = 0
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    let navy = Color(red: 10/255.0, green: 17/255.0, blue: 40/255.0)
    let cream = Color(red: 242/255.0, green: 239/255.0, blue: 233/255.0)
    let inTuneCyan = Color(red: 0/255.0, green: 200/255.0, blue: 255/255.0)
    let warningYellow = Color(red: 255/255.0, green: 204/255.0, blue: 0/255.0)
    let outOfTuneOrange = Color(red: 240/255.0, green: 140/255.0, blue: 50/255.0)
    let dangerRed = Color(red: 255/255.0, green: 59/255.0, blue: 48/255.0)

    var body: some View {
        ZStack {
            navy.ignoresSafeArea()
            
            VStack {
                Text("LONG TONES")
                    .font(.system(size: 24, weight: .black, design: .default))
                    .foregroundColor(cream.opacity(0.6))
                    .padding(.top, 20)
                
                Spacer()
                
                Text(String(format: "%.1f", currentDuration))
                    .font(.system(size: 140, weight: .black, design: .default))
                    .foregroundColor(cream)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                Text("SECONDS")
                    .font(.system(size: 24, weight: .heavy, design: .default))
                    .foregroundColor(cream.opacity(0.6))
                    .offset(y: -10)
                
                HStack(spacing: 40) {
                    VStack {
                        Text("BEST")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(cream.opacity(0.4))
                        Text(String(format: "%.1f", bestDuration))
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(inTuneCyan)
                    }
                    
                    VStack {
                        Text("NOTE")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(cream.opacity(0.4))
                        Text(conductor.data.noteName == "--" ? "..." : conductor.data.noteName)
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(cream)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Pressure gauge
                GeometryReader { geo in
                    let maxVisualDuration = 30.0 // 30 seconds to fill
                    let fillPercentage = min(currentDuration / maxVisualDuration, 1.0)
                    
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(cream.opacity(0.1))
                            .frame(height: 48)
                            .cornerRadius(12)
                        
                        Rectangle()
                            .fill(pressureColor(for: currentDuration))
                            .frame(width: max(geo.size.width * CGFloat(fillPercentage), 0), height: 48)
                            .cornerRadius(12)
                            .animation(.linear(duration: 0.1), value: fillPercentage)
                    }
                }
                .frame(height: 48)
                .padding(.horizontal, 40)
                
                Spacer()
                
                Text(failMessage)
                    .font(.system(size: 20, weight: .black, design: .default))
                    .italic()
                    .foregroundColor(currentDuration > 0 ? inTuneCyan : outOfTuneOrange)
                    .multilineTextAlignment(.center)
                    .rotationEffect(.degrees(-2))
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .animation(.easeInOut, value: failMessage)
            }
        }
        .onAppear {
            conductor.settings = settings
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active { conductor.start() }
            else if newPhase == .background || newPhase == .inactive { conductor.stop() }
        }
        .onReceive(timer) { _ in
            guard conductor.data.isRecording else { return }
            
            // Require a slightly lower volume (0.03 vs 0.05) to help decay instruments like Piano
            if conductor.data.amplitude > 0.03 && conductor.data.noteName != "--" {
                if conductor.data.isInTune(for: settings.mode) {
                    consecutiveFailures = 0 // Reset the grace period counter
                    currentDuration += 0.1
                    
                    if currentDuration > bestDuration {
                        bestDuration = currentDuration
                    }
                    if currentDuration > 0.5 {
                        failMessage = currentDuration > 20 ? "DON'T YOU DARE STOP!" : "HOLD IT."
                    }
                } else {
                    // Out of tune. Increment grace period counter to avoid instant micro-blip fails.
                    consecutiveFailures += 1
                    
                    // If we hit 3 consecutive failures (0.3 seconds total of bad pitch), THEN it counts as a fail.
                    if consecutiveFailures >= 3 {
                        if currentDuration > 0.5 {
                            failMessage = "YOU DROPPED IT! PITCH WENT \(conductor.data.cents > 0 ? "SHARP" : "FLAT")."
                        }
                        currentDuration = 0.0
                        consecutiveFailures = 0
                    }
                }
            } else {
                // Stopped playing or volume completely dropped.
                // We also use the same grace period here so it doesn't instantly die for a microsecond drop in input
                if currentDuration > 0 {
                    consecutiveFailures += 1
                }
                
                if consecutiveFailures >= 3 {
                    if currentDuration > 0.5 {
                        failMessage = "BREATH SUPPORT, NOT WISHFUL THINKING."
                    }
                    currentDuration = 0.0
                    consecutiveFailures = 0
                }
            }
        }
    }
    
    // Shifts from Cyan -> Yellow -> Orange -> Red to simulate pressure building up
    private func pressureColor(for duration: TimeInterval) -> Color {
        if duration < 10 {
            return inTuneCyan
        } else if duration < 20 {
            return warningYellow
        } else if duration < 30 {
            return outOfTuneOrange
        } else {
            return dangerRed
        }
    }
}

#Preview {
    LongToneView()
        .environmentObject(AppSettings())
}
