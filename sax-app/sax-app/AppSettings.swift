import SwiftUI
import Combine

/// Global settings manager for the app.
/// State is persisted so the user doesn't have to re-select their instrument every session.
class AppSettings: ObservableObject {
    @AppStorage("selectedInstrument") var instrumentRawValue: String = Instrument.altoSax.rawValue
    @AppStorage("tuningMode") var modeRawValue: String = TuningMode.casual.rawValue
    
    var instrument: Instrument {
        get { Instrument(rawValue: instrumentRawValue) ?? .altoSax }
        set { instrumentRawValue = newValue.rawValue }
    }
    
    var mode: TuningMode {
        get { TuningMode(rawValue: modeRawValue) ?? .casual }
        set { modeRawValue = newValue.rawValue }
    }
}
