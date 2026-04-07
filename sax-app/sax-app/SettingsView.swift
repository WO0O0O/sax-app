import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    
    let navy = Color(red: 10/255.0, green: 17/255.0, blue: 40/255.0)
    let cream = Color(red: 242/255.0, green: 239/255.0, blue: 233/255.0)
    
    var body: some View {
        ZStack {
            navy.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    Text("SETTINGS")
                        .font(.system(size: 48, weight: .black, design: .default))
                        .foregroundColor(cream)
                        .padding(.top, 20)
                    
                    // Instrument Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("INSTRUMENT & TRANSPOSITION")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(cream.opacity(0.6))
                        
                        VStack(spacing: 12) {
                            ForEach(Instrument.allCases) { inst in
                                selectionRow(
                                    title: inst.rawValue,
                                    subtitle: offsetSubtitle(for: inst),
                                    isSelected: settings.instrument == inst
                                ) {
                                    settings.instrument = inst
                                }
                            }
                        }
                    }
                    
                    // Difficulty Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("FLETCHER TOLERANCE")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(cream.opacity(0.6))
                        
                        VStack(spacing: 12) {
                            ForEach(TuningMode.allCases) { mode in
                                selectionRow(
                                    title: mode.rawValue,
                                    subtitle: toleranceSubtitle(for: mode),
                                    isSelected: settings.mode == mode
                                ) {
                                    settings.mode = mode
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Global Setup")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func selectionRow(title: String, subtitle: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(isSelected ? navy : cream)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isSelected ? navy.opacity(0.7) : cream.opacity(0.5))
                }
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(navy)
                }
            }
            .padding(20)
            .background(isSelected ? cream : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(cream.opacity(0.3), lineWidth: isSelected ? 0 : 2)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func offsetSubtitle(for instrument: Instrument) -> String {
        switch instrument {
        case .concert: return "C Instruments (Piano, Flute)"
        case .altoSax: return "Eb Instruments (+9 Semitones)"
        case .tenorSax: return "Bb Instruments (+14 Semitones)"
        case .trumpet: return "Bb Instruments (+2 Semitones)"
        }
    }
    
    private func toleranceSubtitle(for mode: TuningMode) -> String {
        switch mode {
        case .casual: return "±12 Cents (Standard practice)"
        case .pro: return "±5 Cents (Studio rigor)"
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
}
