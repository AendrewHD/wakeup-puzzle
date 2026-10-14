import Foundation

/// Tiny UserDefaults wrapper shared by the app and the alarm intents.
enum PuzzleState {
    static let changed = Notification.Name("puzzleStateChanged")
    private static let d = UserDefaults.standard

    /// true = an alarm was stopped and the puzzle is not solved yet
    static var pending: Bool {
        get { d.bool(forKey: "pending") }
        set {
            d.set(newValue, forKey: "pending")
            NotificationCenter.default.post(name: changed, object: nil)
        }
    }

    /// true = alarms use a silent sound file (vibration only)
    static var silent: Bool {
        get { d.object(forKey: "silent") as? Bool ?? true }
        set { d.set(newValue, forKey: "silent") }
    }

    static func addNag(_ id: UUID) {
        var ids = d.stringArray(forKey: "nags") ?? []
        ids.append(id.uuidString)
        d.set(ids, forKey: "nags")
    }

    static func takeNags() -> [UUID] {
        let ids = (d.stringArray(forKey: "nags") ?? []).compactMap(UUID.init)
        d.removeObject(forKey: "nags")
        return ids
    }

    static func complete() {
        AlarmScheduler.cancelNags()
        pending = false
    }
}
