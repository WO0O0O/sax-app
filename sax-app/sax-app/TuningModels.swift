import Foundation

/// Defines the instrument transposition and its semitone offset from Concert C.
enum Instrument: String, CaseIterable, Identifiable {
    case concert = "Concert"
    case altoSax = "Alto Sax"
    case tenorSax = "Tenor Sax"
    case trumpet = "Trumpet"
    
    var id: String { self.rawValue }
    
    /// Semitone offset relative to Concert C.
    /// Alto Sax is in Eb, meaning its written C sounds like a Concert Eb.
    /// To get written pitch from concert pitch, we add the offset.
    var semitoneOffset: Int {
        switch self {
        case .concert: return 0
        case .altoSax: return 9 // Eb is +9 semitones
        case .tenorSax: return 14 // Bb Tenor is +14 semitones (but % 12 handles it)
        case .trumpet: return 2 // Bb Trumpet is +2 semitones
        }
    }
}

/// Defines the tuning tolerance for different skill levels.
enum TuningMode: String, CaseIterable, Identifiable {
    case casual = "Casual"
    case pro = "Pro"
    
    var id: String { self.rawValue }
    
    /// Cent tolerance for "In Tune" feedback.
    var tolerance: Double {
        switch self {
        case .casual: return 12.0
        case .pro: return 5.0
        }
    }
}

/// A simple structure to hold the current tuning state for the UI.
struct TunerState {
    var noteName: String = "--"
    var cents: Double = 0.0
    var amplitude: Float = 0.0
    var isRecording: Bool = false
    
    /// Returns true if the current pitch is within the mode's tolerance.
    func isInTune(for mode: TuningMode) -> Bool {
        return abs(cents) <= mode.tolerance && noteName != "--"
    }
}

struct FletcherFeedback {
    static let flatInsults = [
        "ARE YOU RUSHING OR ARE YOU DRAGGING?!",
        "YOU'RE FLAT, YOU *****!",
        "MY GRANDMOTHER PLAYS SHARPER THAN YOU, AND SHE'S INTERRED!",
        "IF YOU PLAY ONE MORE FLAT NOTE I WILL ***** HURL THIS TUNER AT YOUR HEAD!",
        "WERE YOU BORN WITHOUT EARS OR JUST WITHOUT A ***** SOUL?"
    ]
    
    static let sharpInsults = [
        "TOO SHARP! YOU'RE BURNING MY ***** EARS!",
        "NOT QUITE MY TEMPO, YOU *****!",
        "YOU'RE SO SHARP YOU'RE PRACTICALLY IN THE NEXT ***** KEY!",
        "STOP PUSHING THE AIR LIKE A ***** AMATEUR!",
        "IS THAT A SAXOPHONE OR A ***** TEA KETTLE?!"
    ]
    
    static let inTuneComments = [
        "DON'T GET COMPLACENT.",
        "FOR ONCE, YOU'RE NOT A COMPLETE ***** DISASTER.",
        "ACCEPTABLE. BARELY.",
        "STAY THERE. DON'T YOU ***** MOVE."
    ]
    
    static func getInsult(cents: Double, isInTune: Bool) -> String {
        if isInTune {
            return inTuneComments.randomElement()!
        } else if cents < 0 {
            return flatInsults.randomElement()!
        } else {
            return sharpInsults.randomElement()!
        }
    }
}
