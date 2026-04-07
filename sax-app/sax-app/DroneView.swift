import SwiftUI

struct DroneView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var conductor = DroneConductor()
    
    @State private var selectedNoteIndex = 0
    let notes = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#", "A", "Bb", "B"]
    
    let navy = Color(red: 10/255.0, green: 17/255.0, blue: 40/255.0)
    let cream = Color(red: 242/255.0, green: 239/255.0, blue: 233/255.0)
    let inTuneCyan = Color(red: 0/255.0, green: 200/255.0, blue: 255/255.0)

    var body: some View {
        ZStack {
            navy.ignoresSafeArea()
            
            VStack {
                Text("DRONE GENERATOR")
                    .font(.system(size: 24, weight: .black, design: .default))
                    .foregroundColor(cream.opacity(0.6))
                    .padding(.top, 20)
                
                Spacer()
                
                // Massive Note Selector
                HStack(alignment: .center) {
                    Button(action: {
                        changeNote(by: -1)
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 60, weight: .black))
                            .foregroundColor(cream.opacity(0.5))
                    }
                    
                    Text(notes[selectedNoteIndex])
                        .font(.system(size: 140, weight: .black, design: .default))
                        .foregroundColor(conductor.isPlaying ? inTuneCyan : cream)
                        .frame(width: 220)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    Button(action: {
                        changeNote(by: 1)
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 60, weight: .black))
                            .foregroundColor(cream.opacity(0.5))
                    }
                }
                
                Text("\(settings.instrument.rawValue) Pitch")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(cream.opacity(0.6))
                    .padding(.top, -10)
                
                Spacer()
                
                // Giant Play Button
                Button(action: {
                    toggleDrone()
                }) {
                    ZStack {
                        Circle()
                            .fill(conductor.isPlaying ? inTuneCyan.opacity(0.2) : cream.opacity(0.1))
                            .frame(width: 160, height: 160)
                        
                        Image(systemName: conductor.isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 60))
                            .foregroundColor(conductor.isPlaying ? inTuneCyan : cream)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: conductor.isPlaying)
                
                Spacer()
                
                // Volume Slider
                VStack(spacing: 8) {
                    Text("DRONE VOLUME")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(cream.opacity(0.4))
                    
                    Slider(value: $conductor.volume, in: 0...1)
                        .accentColor(inTuneCyan)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            conductor.setPitch(noteIndex: selectedNoteIndex, instrument: settings.instrument)
        }
        .onDisappear {
            conductor.stop()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background || newPhase == .inactive {
                conductor.stop()
            }
        }
        .onChange(of: settings.instrument) { _, newInstrument in
            conductor.setPitch(noteIndex: selectedNoteIndex, instrument: newInstrument)
        }
    }
    
    private func changeNote(by step: Int) {
        var newIndex = selectedNoteIndex + step
        if newIndex < 0 { newIndex = notes.count - 1 }
        if newIndex >= notes.count { newIndex = 0 }
        
        selectedNoteIndex = newIndex
        conductor.setPitch(noteIndex: selectedNoteIndex, instrument: settings.instrument)
    }
    
    private func toggleDrone() {
        if conductor.isPlaying {
            conductor.stop()
        } else {
            conductor.setPitch(noteIndex: selectedNoteIndex, instrument: settings.instrument)
            conductor.start()
        }
    }
}

#Preview {
    DroneView()
        .environmentObject(AppSettings())
}
