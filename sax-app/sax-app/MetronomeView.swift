import SwiftUI

struct MetronomeView: View {
    @StateObject private var conductor = MetronomeConductor()
    @Environment(\.scenePhase) var scenePhase
    
    let navy = Color(red: 10/255.0, green: 17/255.0, blue: 40/255.0)
    let cream = Color(red: 242/255.0, green: 239/255.0, blue: 233/255.0)
    let inTuneCyan = Color(red: 0/255.0, green: 200/255.0, blue: 255/255.0)

    var body: some View {
        ZStack {
            navy.ignoresSafeArea()
            
            // Subtle background pulse on the beat
            if conductor.beatFlash {
                inTuneCyan.opacity(0.35)
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                Text("METRONOME")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(cream.opacity(0.6))
                    .padding(.top, 20)
                
                Spacer()
                
                // Beat indicator dots
                HStack(spacing: 20) {
                    ForEach(1...4, id: \.self) { beat in
                        Circle()
                            .fill(beat == conductor.currentBeat && conductor.isPlaying ? inTuneCyan : cream.opacity(0.2))
                            .frame(width: beat == 1 ? 28 : 20, height: beat == 1 ? 28 : 20)
                            .animation(.easeOut(duration: 0.08), value: conductor.currentBeat)
                    }
                }
                .padding(.bottom, 30)
                
                // BPM Display + -/+ Controls
                HStack(alignment: .center, spacing: 30) {
                    Button(action: {
                        if conductor.bpm > 40 {
                            conductor.bpm -= 1
                            if conductor.isPlaying { conductor.stop(); conductor.start() }
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(cream.opacity(0.5))
                    }

                    VStack(spacing: -12) {
                        Text("\(Int(conductor.bpm))")
                            .font(.system(size: 140, weight: .black))
                            .foregroundColor(cream)
                            .contentTransition(.numericText())
                            .animation(.snappy, value: conductor.bpm)
                            .frame(minWidth: 230)
                        
                        Text("BPM")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(cream.opacity(0.6))
                    }
                    
                    Button(action: {
                        if conductor.bpm < 300 {
                            conductor.bpm += 1
                            if conductor.isPlaying { conductor.stop(); conductor.start() }
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(cream.opacity(0.5))
                    }
                }
                
                Spacer()
                
                // Tap Tempo + Play/Stop
                HStack(spacing: 40) {
                    Button(action: { conductor.tapTempo() }) {
                        Text("TAP")
                            .font(.system(size: 22, weight: .black))
                            .frame(width: 110, height: 110)
                            .background(cream.opacity(0.1))
                            .foregroundColor(cream)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(cream.opacity(0.3), lineWidth: 2))
                    }
                    
                    Button(action: {
                        if conductor.isPlaying { conductor.stop() }
                        else { conductor.start() }
                    }) {
                        ZStack {
                            Circle()
                                .fill(conductor.isPlaying ? inTuneCyan.opacity(0.25) : cream.opacity(0.1))
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: conductor.isPlaying ? "stop.fill" : "play.fill")
                                .font(.system(size: 54))
                                .foregroundColor(conductor.isPlaying ? inTuneCyan : cream)
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: conductor.isPlaying)
                }
                .padding(.bottom, 60)
            }
        }
        .onDisappear { conductor.stop() }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active { conductor.stop() }
        }
    }
}

#Preview {
    MetronomeView()
}
