import SwiftUI

struct SightReadingView: View {
    @StateObject private var conductor = SightReadingConductor()
    @EnvironmentObject var settings: AppSettings
    
    let navy = Color(red: 10/255.0, green: 17/255.0, blue: 40/255.0)
    let cream = Color(red: 242/255.0, green: 239/255.0, blue: 233/255.0)
    let cyanAccent = Color(red: 0/255.0, green: 255/255.0, blue: 255/255.0)
    let orangeAccent = Color(red: 255/255.0, green: 140/255.0, blue: 0/255.0)
    
    var body: some View {
        ZStack {
            navy.ignoresSafeArea()
            
            VStack {
                // Header & Stats
                HStack {
                    VStack(alignment: .leading) {
                        Text("Sight Reading")
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(cream)
                        Text("Alto Sax written range")
                            .font(.caption)
                            .foregroundColor(cream.opacity(0.6))
                    }
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        if conductor.highScore > 0 {
                            Text("Best: \(conductor.highScore)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(cream.opacity(0.8))
                        }
                        Text("Time: \(conductor.timeRemaining)s")
                            .font(.headline)
                            .foregroundColor(conductor.timeRemaining <= 10 ? Color.red : cyanAccent)
                        Text("Score: \(conductor.score)")
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundColor(orangeAccent)
                    }
                }
                .padding()
                
                Spacer()
                
                // Staff Display Area
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(cream.opacity(0.05))
                        .frame(height: 300)
                    
                    // Draw Staff
                    StaffView(prompt: conductor.currentPrompt)
                        .frame(height: 150)
                        .padding(.horizontal, 40)
                    
                    if conductor.gameState == .waitingToStart || conductor.gameState == .gameOver {
                        Color.black.opacity(0.6)
                            .frame(height: 300)
                            .cornerRadius(16)
                        
                        Button(action: {
                            conductor.startGame()
                        }) {
                            Text(conductor.gameState == .gameOver ? "PLAY AGAIN" : "START DRILL")
                                .font(.system(size: 24, weight: .black))
                                .padding(.horizontal, 40)
                                .padding(.vertical, 16)
                                .background(cyanAccent)
                                .foregroundColor(navy)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                // Feedback below staff
                Text(conductor.feedbackMessage)
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(cream)
                    .multilineTextAlignment(.center)
                    .frame(height: 80)
                
                // Current tracking info so user can see what they are actually outputting
                if conductor.gameState == .playing {
                    HStack {
                        Text("Hearing: ")
                            .foregroundColor(cream.opacity(0.6))
                        Text(conductor.currentNoteForUI)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(cyanAccent)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            conductor.settings = settings
        }
        .onDisappear {
            conductor.stop()
        }
    }
}

// Custom view to draw the 5 lines and the note
struct StaffView: View {
    var prompt: SightReadingPrompt?
    let cream = Color(red: 242/255.0, green: 239/255.0, blue: 233/255.0)

    var body: some View {
        GeometryReader { geo in
            let staffHeight = geo.size.height
            let lineSpacing = staffHeight / 4 // 5 lines means 4 spaces
            
            ZStack {
                // Draw the 5 horizontal lines
                ForEach(0..<5) { index in
                    Path { path in
                        let y = CGFloat(index) * lineSpacing
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    }
                    .stroke(cream.opacity(0.6), lineWidth: 2)
                }
                
                // Treble Clef (𝄞)
                Text("𝄞")
                    .font(.system(size: lineSpacing * 6.5))
                    .foregroundColor(cream)
                    .position(x: 30, y: lineSpacing * 2) 
                    
                // Draw the Note if active
                if let prompt = prompt {
                    // C4 (Middle C) staff position = 0
                    // Staff Bottom Line (E4) staff position = 2
                    // Since E4 is at y = staffHeight (index 4 * lineSpacing)
                    
                    let bottomLineY = staffHeight
                    let offsetPerPosition = lineSpacing / 2
                    
                    let relativePosition = prompt.staffPosition - 2 // Relative to E4
                    
                    let noteY = bottomLineY - (CGFloat(relativePosition) * offsetPerPosition)
                    let noteX = geo.size.width / 2
                    
                    // Draw Ledger Lines if necessary
                    if prompt.staffPosition <= 0 { // C4
                        Path { path in
                            path.move(to: CGPoint(x: noteX - 25, y: noteY))
                            path.addLine(to: CGPoint(x: noteX + 25, y: noteY))
                        }
                        .stroke(cream.opacity(0.8), lineWidth: 2)
                    } else if prompt.staffPosition >= 12 { // A5 and above
                        let ledgerLineCount = (prompt.staffPosition - 10) / 2
                        ForEach(1...ledgerLineCount, id: \.self) { i in
                            let ledY = bottomLineY - (CGFloat(10 + (i * 2) - 2) * offsetPerPosition)
                            Path { path in
                                path.move(to: CGPoint(x: noteX - 25, y: ledY))
                                path.addLine(to: CGPoint(x: noteX + 25, y: ledY))
                            }
                            .stroke(cream.opacity(0.8), lineWidth: 2)
                        }
                    }
                    
                    // The Note Head
                    // Use a slightly squashed circle typical of sheet music
                    Ellipse()
                        .fill(Color(red: 0/255.0, green: 255/255.0, blue: 255/255.0))
                        .frame(width: lineSpacing * 1.6, height: lineSpacing * 1.1)
                        .position(x: noteX, y: noteY)
                        // Note Stem
                        .overlay(
                            Path { path in
                                // If the note is on the middle line (position 6, B4) or above, stems go down. Else stems go up.
                                let stemUp = prompt.staffPosition < 6
                                let stemHeight: CGFloat = lineSpacing * 3.5
                                
                                if stemUp {
                                    // Stem draws up from the right side of the notehead
                                    path.move(to: CGPoint(x: (lineSpacing * 1.6) / 2 - 2, y: 0))
                                    path.addLine(to: CGPoint(x: (lineSpacing * 1.6) / 2 - 2, y: -stemHeight))
                                } else {
                                    // Stem draws down from the left side of the notehead
                                    path.move(to: CGPoint(x: -(lineSpacing * 1.6) / 2 + 2, y: 0))
                                    path.addLine(to: CGPoint(x: -(lineSpacing * 1.6) / 2 + 2, y: stemHeight))
                                }
                            }
                            .stroke(Color(red: 0/255.0, green: 255/255.0, blue: 255/255.0), lineWidth: 2)
                            .position(x: noteX, y: noteY) // Re-anchor the path
                        )
                }
            }
        }
    }
}

#Preview {
    SightReadingView()
        .environmentObject(AppSettings())
}
