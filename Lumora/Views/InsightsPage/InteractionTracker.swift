// InteractionTracker.swift
// Lumora

import Foundation
import Observation

@Observable
final class InteractionTracker {
    static let shared = InteractionTracker()

    private let defaults = UserDefaults.standard
    private let key = "interactionDays" // now stores all logged interactions
    private let calendar = Calendar.current

    // Exposed to UI
    private(set) var currentStreak: Int = 0

    init() {
        recomputeStreak()
    }

    // MARK: - Public logging

    func logInteraction(for date: Date) {
        var days = loadDays()
        let id = dayId(for: date)

        // ✅ Append even if it already exists
        days.append(id)
        saveDays(days)

        // ✅ Streak is simply number of logs
        currentStreak = days.count
    }

    func logTodayInteraction() {
        logInteraction(for: Date())
    }

    func logRandomInteraction() {
        let offset = Int.random(in: 0..<60)
        guard let randomDate = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return }
        logInteraction(for: randomDate)
        print("Logged random date:", dayId(for: randomDate), "| Streak:", currentStreak)
    }

    func clearAll() {
        defaults.removeObject(forKey: key)
        currentStreak = 0
    }

    // MARK: - Persistence

    private func loadDays() -> [String] {
        defaults.stringArray(forKey: key) ?? []
    }

    private func saveDays(_ days: [String]) {
        defaults.set(days, forKey: key)
    }

    private func recomputeStreak() {
        currentStreak = loadDays().count
    }

    // MARK: - Day formatting

    private func dayId(for date: Date) -> String {
        let df = DateFormatter()
        df.calendar = calendar
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone.current
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: date)
    }
}
