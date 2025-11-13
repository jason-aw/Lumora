// MARK: - ViewModel (stubbed data)
import Foundation

@Observable
final class InsightsViewModel {
    var streakNights: Int = 1
    var moodTrendSummary: String = "hi"
    var aiIntro: String = ""
    var aiBullets: [String] = []
    
    // Persistence
    private let streakKey = "Insights.streakNights"
    // A per-launch token to ensure we only increment once per app process
    private static var didIncrementThisLaunch = false

    init() {
        loadPersisted()
        incrementOncePerLaunch()
    }
    
    private func loadPersisted() {
        let defaults = UserDefaults.standard
        
        // Keep default 10 if nothing saved yet
        if defaults.object(forKey: streakKey) != nil {
            streakNights = max(1, defaults.integer(forKey: streakKey))
        } else {
            streakNights = 10
            defaults.set(streakNights, forKey: streakKey)
        }
    }
    
    // Increment the streak a single time per app process launch
    private func incrementOncePerLaunch() {
        guard !Self.didIncrementThisLaunch else { return }
        Self.didIncrementThisLaunch = true
        
        streakNights += 1
        UserDefaults.standard.set(streakNights, forKey: streakKey)
    }
}
