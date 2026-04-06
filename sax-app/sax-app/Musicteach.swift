import SwiftUI

@main
struct Musicteach: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            // To ensure the dark theme works flawlessly across the system
            .preferredColorScheme(.dark)
        }
    }
}
