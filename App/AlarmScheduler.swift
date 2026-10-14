import ActivityKit
import AlarmKit
import AppIntents
import SwiftUI

struct WakeMetadata: AlarmMetadata {}

/// Stop button pressed -> remember the puzzle is open and re-arm a "nag" alarm.
/// The nag keeps ringing every ~45 s until the puzzle is solved.
struct StopAlarmIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Stop alarm"
    static let openAppWhenRun = true

    @Parameter(title: "alarmID") var alarmID: String

    init(alarmID: String) { self.alarmID = alarmID }
    init() {}

    func perform() async throws -> some IntentResult {
        PuzzleState.pending = true
        await AlarmScheduler.scheduleNag()
        return .result()
    }
}

enum AlarmScheduler {
    private static let manager = AlarmManager.shared

    static func authorize() async -> Bool {
        switch manager.authorizationState {
        case .authorized: return true
        case .notDetermined:
            return (try? await manager.requestAuthorization()) == .authorized
        default: return false
        }
    }

    private static func configuration(id: UUID, schedule: Alarm.Schedule)
        -> AlarmManager.AlarmConfiguration<WakeMetadata> {
        let stop = AlarmButton(text: LocalizedStringResource("Stop"), textColor: .white, systemImageName: "stop.circle")
        let alert = AlarmPresentation.Alert(title: LocalizedStringResource("Wake up - solve the puzzle"),
                                            stopButton: stop)
        let attributes = AlarmAttributes(
            presentation: AlarmPresentation(alert: alert),
            metadata: WakeMetadata(),
            tintColor: .orange)
        return .alarm(
            schedule: schedule,
            attributes: attributes,
            stopIntent: StopAlarmIntent(alarmID: id.uuidString),
            secondaryIntent: nil,
            sound: PuzzleState.silent ? .named("silence.wav") : .default)
    }

    /// Create or replace the AlarmKit alarm for one item.
    static func sync(_ item: AlarmItem) async {
        cancel(item.id)
        guard item.enabled, await authorize() else { return }
        PuzzleState.silent = item.vibrationOnly

        let map: [Int: Locale.Weekday] = [1: .sunday, 2: .monday, 3: .tuesday, 4: .wednesday,
                                          5: .thursday, 6: .friday, 7: .saturday]
        let days = item.weekdays.sorted().compactMap { map[$0] }
        let schedule = Alarm.Schedule.relative(.init(
            time: .init(hour: item.hour, minute: item.minute),
            repeats: days.isEmpty ? .never : .weekly(days)))
        _ = try? await manager.schedule(id: item.id, configuration: configuration(id: item.id, schedule: schedule))
    }

    static func cancel(_ id: UUID) {
        try? manager.cancel(id: id)
    }

    /// One-off alarm after `seconds`. Used for the nag and for the "Test in 1 min" button.
    static func scheduleNag(after seconds: TimeInterval = 45) async {
        guard await authorize() else { return }
        let id = UUID()
        let schedule = Alarm.Schedule.fixed(Date().addingTimeInterval(seconds))
        if (try? await manager.schedule(id: id, configuration: configuration(id: id, schedule: schedule))) != nil {
            PuzzleState.addNag(id)
        }
    }

    static func cancelNags() {
        for id in PuzzleState.takeNags() { cancel(id) }
    }
}
