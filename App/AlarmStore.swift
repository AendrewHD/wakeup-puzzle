import Foundation

struct AlarmItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var hour = 7
    var minute = 0
    var weekdays: [Int] = []      // Calendar weekday: 1 = Sunday ... 7 = Saturday. Empty = once.
    var label = "Wake up"
    var vibrationOnly = true
    var enabled = true
}

@MainActor
final class AlarmStore: ObservableObject {
    @Published private(set) var alarms: [AlarmItem] = []
    private let key = "alarms.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let list = try? JSONDecoder().decode([AlarmItem].self, from: data) {
            alarms = list
        }
    }

    func save(_ item: AlarmItem) {
        if let i = alarms.firstIndex(where: { $0.id == item.id }) {
            alarms[i] = item
        } else {
            alarms.append(item)
        }
        persist()
        Task { await AlarmScheduler.sync(item) }
    }

    func delete(at offsets: IndexSet) {
        for i in offsets { AlarmScheduler.cancel(alarms[i].id) }
        alarms.remove(atOffsets: offsets)
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
