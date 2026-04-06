import SwiftUI

struct ContentView: View {
    @StateObject private var conductor = TunerConductor()
    @Environment(\.scenePhase) var scenePhase

    // Blue Note Theme Colors
    let navy = Color(red: 10/255.0, green: 17/255.0, blue: 40/255.0)
    let cream = Color(red: 242/255.0, green: 239/255.0, blue: 233/255.0)
    let inTuneCyan = Color(red: 0/255.0, green: 200/255.0, blue: 255/255.0)
    let outOfTuneOrange = Color(red: 240/255.0, green: 140/255.0, blue: 50/255.0)

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            ZStack {
                navy.ignoresSafeArea()
                
                if isLandscape {
                    // MARK: - Premium Landscape Sweeping Design
                    VStack(spacing: 0) {
                        // Top Bar: Header & Controls
                        HStack(alignment: .top) {
                            header
                            Spacer()
                            controls
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 40)
                        
                        Spacer()
                        
                        // Absolute Centerpiece
                        VStack(spacing: 40) {
                            Text(conductor.data.noteName)
                                .font(.system(size: 280, weight: .black, design: .default))
                                .foregroundColor(cream)
                                .lineLimit(1)
                                .minimumScaleFactor(0.4)
                            
                            // Horizontal Sweeping Gauge
                            ZStack(alignment: .center) {
                                // Track line
                                Rectangle()
                                    .fill(cream.opacity(0.15))
                                    .frame(width: geometry.size.width * 0.6, height: 6)
                                
                                let inTune = conductor.data.isInTune(for: conductor.mode)
                                let gaugeColor = inTune ? inTuneCyan : outOfTuneOrange
                                
                                // Map cents (-50 to +50) to horizontal width dynamically based on iPad screen size
                                let maxOffset = (geometry.size.width * 0.6) / 2.0
                                let xOffset = CGFloat(max(min(conductor.data.cents, 50), -50)) * (maxOffset / 50.0)
                                
                                // Indicator block
                                Rectangle()
                                    .fill(gaugeColor)
                                    .frame(width: inTune ? 40 : 20, height: inTune ? 24 : 12)
                                    .offset(x: inTune ? 0 : xOffset) // Snaps dead center when perfectly in tune
                                    .animation(.interactiveSpring(response: 0.15, dampingFraction: 0.8), value: xOffset)
                                    .animation(.easeInOut(duration: 0.2), value: inTune)
                                
                                // True Center line tick
                                Rectangle()
                                    .fill(cream.opacity(0.8))
                                    .frame(width: 4, height: 32)
                            }
                        }
                        // Visually center it higher up to offset the heavy footer mass
                        .offset(y: -40)
                        
                        Spacer()
                        
                        // Bottom Bar: Deviation, Fletcher, and Spacer block
                        HStack(alignment: .bottom) {
                            // Cents Readout (Left)
                            footer(alignment: .leading)
                            
                            Spacer()
                            
                            // Fletcher Feedback (Center)
                            Text(conductor.currentInsult)
                                .font(.system(size: 26, weight: .black, design: .default))
                                .italic()
                                .foregroundColor(conductor.data.isInTune(for: conductor.mode) ? inTuneCyan : outOfTuneOrange)
                                .multilineTextAlignment(.center)
                                .rotationEffect(.degrees(-2))
                                .frame(maxWidth: .infinity)
                            
                            Spacer()
                            
                            // Invisible block to perfectly center Fletcher Feedback symmetrically
                            footer(alignment: .trailing).opacity(0)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    }
                } else {
                    // MARK: - Portrait Layout
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top) {
                            header
                            Spacer()
                            controls
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        // Fletcher Output
                        HStack {
                            Spacer()
                            Text(conductor.currentInsult)
                                .font(.system(size: 20, weight: .black, design: .default))
                                .italic()
                                .foregroundColor(conductor.data.isInTune(for: conductor.mode) ? inTuneCyan : outOfTuneOrange)
                                .multilineTextAlignment(.center)
                                .rotationEffect(.degrees(-3))
                                .padding(.horizontal, 20)
                            Spacer()
                        }
                        .padding(.bottom, 20)

                        // Vertical Main Note Display & Visualizer
                        HStack(alignment: .center) {
                            Text(conductor.data.noteName)
                                .font(.system(size: 160, weight: .black, design: .default))
                                .foregroundColor(cream)
                                .minimumScaleFactor(0.5)
                                .frame(width: 200, alignment: .trailing)
                            
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(cream.opacity(0.2))
                                    .frame(width: 8, height: 180)
                                    .offset(x: 20)
                                
                                let inTune = conductor.data.isInTune(for: conductor.mode)
                                let gaugeColor = inTune ? inTuneCyan : outOfTuneOrange
                                
                                let yOffset = CGFloat(max(min(conductor.data.cents, 50), -50)) * -1.6
                                
                                Rectangle()
                                    .fill(gaugeColor)
                                    .frame(width: inTune ? 40 : 20, height: inTune ? 16 : 8)
                                    .offset(x: inTune ? 4 : 14, y: yOffset)
                                    .animation(.interactiveSpring(response: 0.15, dampingFraction: 0.8), value: yOffset)
                                    .animation(.easeInOut(duration: 0.2), value: inTune)
                            }
                            .frame(height: 200)
                            
                            Spacer()
                        }
                        .padding(.leading, 20)

                        Spacer()
                        
                        HStack {
                            Spacer()
                            footer(alignment: .trailing)
                        }
                        .padding(32)
                    }
                }
            }
        }
        .onAppear { conductor.start() }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active { conductor.start() }
            else if newPhase == .background || newPhase == .inactive { conductor.stop() }
        }
    }
    
    // MARK: - Extracted Components
    
    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: -5) {
            Text("BLUE NOTE")
                .font(.system(size: 38, weight: .black, design: .default))
            Text("TUNER")
                .font(.system(size: 38, weight: .black, design: .default))
        }
        .foregroundColor(cream)
    }
    
    @ViewBuilder
    private var controls: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Menu {
                Picker("Instrument", selection: $conductor.instrument) {
                    ForEach(Instrument.allCases) { inst in
                        Text(inst.rawValue).tag(inst)
                    }
                }
            } label: {
                HStack {
                    Text(conductor.instrument.rawValue)
                    Image(systemName: "chevron.down")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(navy)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(cream)
            }

            Menu {
                Picker("Mode", selection: $conductor.mode) {
                    ForEach(TuningMode.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
            } label: {
                HStack {
                    Text(conductor.mode.rawValue)
                    Image(systemName: "chevron.down")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(navy)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(cream)
            }
        }
    }
    
    @ViewBuilder
    private func footer(alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 0) {
            let centsText = conductor.data.noteName == "--" ? "0.0" : String(format: "%.1f", conductor.data.cents)
            let inTune = conductor.data.isInTune(for: conductor.mode)
            
            Text("\(centsText) ¢")
                .font(.system(size: 48, weight: .heavy, design: .default))
                .foregroundColor(inTune ? inTuneCyan : cream)
                .animation(.easeInOut, value: inTune)
            
            Text("DEVIATION")
                .font(.system(size: 14, weight: .bold, design: .default))
                .foregroundColor(cream.opacity(0.6))
        }
    }
}

#Preview {
    ContentView()
}
