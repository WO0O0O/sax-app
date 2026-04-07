import SwiftUI

/// Defines the selectable screens in the sidebar
enum AppScreen: String, CaseIterable, Identifiable {
    case tuner = "Tuner"
    case endurance = "Long Tones"
    case drone = "Drone"
    case metronome = "Metronome"
    case stats = "Analytics"
    case sheetMusic = "Sight Reading"
    case settings = "Settings"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .tuner: return "tuningfork"
        case .endurance: return "stopwatch"
        case .drone: return "speaker.wave.3"
        case .metronome: return "metronome"
        case .stats: return "chart.bar.xaxis"
        case .sheetMusic: return "music.note.list"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainView: View {
    @State private var selectedScreen: AppScreen? = .tuner
    @StateObject private var settings = AppSettings()
    
    let navy = Color(red: 10/255.0, green: 17/255.0, blue: 40/255.0)
    let cream = Color(red: 242/255.0, green: 239/255.0, blue: 233/255.0)

    var body: some View {
        // NavigationSplitView creates the sidebar
        NavigationSplitView {
            ZStack {
                navy.ignoresSafeArea()
                
                List(selection: $selectedScreen) {
                    Section("BLUE NOTE SUITE") {
                        NavigationLink(value: AppScreen.tuner) {
                            Label(AppScreen.tuner.rawValue, systemImage: AppScreen.tuner.iconName)
                        }
                        NavigationLink(value: AppScreen.endurance) {
                            Label(AppScreen.endurance.rawValue, systemImage: AppScreen.endurance.iconName)
                        }
                        NavigationLink(value: AppScreen.drone) {
                            Label(AppScreen.drone.rawValue, systemImage: AppScreen.drone.iconName)
                        }
                        NavigationLink(value: AppScreen.metronome) {
                            Label(AppScreen.metronome.rawValue, systemImage: AppScreen.metronome.iconName)
                        }
                        NavigationLink(value: AppScreen.stats) {
                            Label(AppScreen.stats.rawValue, systemImage: AppScreen.stats.iconName)
                        }
                        NavigationLink(value: AppScreen.sheetMusic) {
                            Label(AppScreen.sheetMusic.rawValue, systemImage: AppScreen.sheetMusic.iconName)
                        }
                    }
                    .foregroundColor(cream)
                    .listRowBackground(navy)
                    
                    Section("PREFERENCES") {
                        NavigationLink(value: AppScreen.settings) {
                            Label(AppScreen.settings.rawValue, systemImage: AppScreen.settings.iconName)
                        }
                    }
                    .foregroundColor(cream)
                    .listRowBackground(navy)
                }
                .scrollContentBackground(.hidden) // Removes default iOS list background
            }
            .navigationTitle("Menu")
        } detail: {
            // The detail view resolves which screen to show based on the selection
            Group {
                switch selectedScreen {
                case .tuner:
                    ContentView()
                case .endurance:
                    LongToneView()
                case .drone:
                    DroneView()
                case .metronome:
                    MetronomeView()
                case .stats:
                    StatsView()
                case .sheetMusic:
                    SightReadingView()
                case .settings:
                    SettingsView()
                case .none:
                    Text("Select a tool from the menu")
                        .foregroundColor(cream)
                }
            }
            // Inject our global AppSettings down the hierarchy so Tuner and Settings can see it
            .environmentObject(settings)
        }
        // Force split view style on iPad so it looks like a sidebar instead of stacked menus
        .navigationSplitViewStyle(.balanced) 
        // We ensure we force dark mode here to stick to the aesthetic even if user changes phone to Light
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainView()
}
