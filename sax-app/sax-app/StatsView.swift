import SwiftUI
import Charts

struct StatsView: View {
    @StateObject private var conductor = StatsConductor()
    @EnvironmentObject var settings: AppSettings
    
    let navy = Color(red: 10/255.0, green: 17/255.0, blue: 40/255.0)
    let cream = Color(red: 242/255.0, green: 239/255.0, blue: 233/255.0)
    let cyanAccent = Color(red: 0/255.0, green: 255/255.0, blue: 255/255.0)
    let orangeAccent = Color(red: 255/255.0, green: 140/255.0, blue: 0/255.0)
    
    var body: some View {
        ZStack {
            navy.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Intonation Tendencies")
                            .font(.system(size: 32, weight: .black, design: .default))
                            .foregroundColor(cream)
                        
                        if conductor.isTracking {
                            Text("Time: \(String(format: "%02d:%02d", conductor.sessionTime / 60, conductor.sessionTime % 60))")
                                .font(.headline)
                                .foregroundColor(cyanAccent)
                        } else {
                            Text("Analyze your \(settings.instrument.rawValue) pitch trends.")
                                .font(.caption)
                                .foregroundColor(cream.opacity(0.6))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {
                        conductor.resetStats()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(cream.opacity(0.8))
                            .padding(12)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Text("Analyze which notes on your \(settings.instrument.rawValue) systematically trend sharp or flat.")
                    .font(.subheadline)
                    .foregroundColor(cream.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                // Start / Stop Tracking Button
                Button(action: {
                    conductor.toggleTracking()
                }) {
                    HStack {
                        Image(systemName: conductor.isTracking ? "stop.circle.fill" : "play.circle.fill")
                        Text(conductor.isTracking ? "Stop Drill" : "Start Analytics Drill")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(conductor.isTracking ? navy : cyanAccent)
                    .background(conductor.isTracking ? cyanAccent : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(cyanAccent, lineWidth: 2)
                    )
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                if conductor.isTracking {
                    HStack {
                        // Flashing recording indicator
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                            // Basic opacity animation to pulse
                            .opacity(conductor.sessionTime % 2 == 0 ? 1.0 : 0.3)
                            .animation(.easeInOut(duration: 1.0), value: conductor.sessionTime)
                        
                        Text("Analyzing: \(conductor.currentNoteForUI)")
                            .font(.headline)
                            .foregroundColor(cyanAccent)
                    }
                } else {
                    Text("Start drill to analyze...")
                        .font(.headline)
                        .foregroundColor(cream.opacity(0.5))
                }
                
                // Chart Area
                if conductor.recordedStats.isEmpty {
                    Spacer()
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 60))
                        .foregroundColor(cream.opacity(0.3))
                        .padding(.bottom, 8)
                    Text("No data recorded yet.")
                        .foregroundColor(cream.opacity(0.5))
                    Spacer()
                } else {
                    // Filter to sort notes chromatically if needed, 
                    // but recordedStats is already sorted alphabetically by noteName for now.
                    // A better approach would be to sort by pitch class, but alphabetical works for a basic view.
                    
                    Chart(conductor.recordedStats.sorted(by: { $0.noteName < $1.noteName })) { stat in
                        BarMark(
                            x: .value("Note", stat.noteName),
                            y: .value("Cents Deviation", stat.averageCentsDeviation)
                        )
                        .foregroundStyle(stat.averageCentsDeviation >= 0 ? orangeAccent : cyanAccent)
                        .annotation(position: stat.averageCentsDeviation >= 0 ? .top : .bottom) {
                            Text("\(Int(stat.averageCentsDeviation))")
                                .font(.caption2)
                                .foregroundColor(cream.opacity(0.7))
                        }
                    }
                    .chartYScale(domain: -50...50) // Force -50 to 50 cents range
                    .chartYAxis {
                        AxisMarks(position: .leading, values: [-50, -25, 0, 25, 50]) { value in
                            AxisGridLine().foregroundStyle(cream.opacity(0.2))
                            AxisValueLabel().foregroundStyle(cream.opacity(0.7))
                        }
                    }
                    .chartXAxis {
                        AxisMarks(position: .bottom) { value in
                            AxisValueLabel().foregroundStyle(cream)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(16)
                    .padding()
                    
                    Text("Positive (Orange) is SHARP. Negative (Cyan) is FLAT.")
                        .font(.caption)
                        .foregroundColor(cream.opacity(0.6))
                        .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            conductor.settings = settings
        }
        .onDisappear {
            conductor.stopTracking()
        }
    }
}

#Preview {
    StatsView()
        .environmentObject(AppSettings())
}
