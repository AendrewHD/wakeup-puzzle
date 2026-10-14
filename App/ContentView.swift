import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AlarmStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var pending = PuzzleState.pending
    @State private var editing: AlarmItem?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.alarms) { alarm in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(String(format: "%02d:%02d", alarm.hour, alarm.minute))
                                .font(.system(size: 40, weight: .light, design: .rounded))
                            Text(subtitle(alarm)).font(.footnote).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { alarm.enabled },
                            set: { var a = alarm; a.enabled = $0; store.save(a) }))
                            .labelsHidden()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { editing = alarm }
                }
                .onDelete { store.delete(at: $0) }
            }
            .navigationTitle("WakeUp Puzzle")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Test 1 min") { Task { await AlarmScheduler.scheduleNag(after: 60) } }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { editing = AlarmItem() } label: { Image(systemName: "plus") }
                }
            }
            .sheet(item: $editing) { item in
                AlarmEditView(item: item) { store.save($0) }
            }
        }
        .fullScreenCover(isPresented: $pending) { PuzzleView() }
        .onReceive(NotificationCenter.default.publisher(for: PuzzleState.changed)) { _ in
            pending = PuzzleState.pending
        }
        .onChange(of: scenePhase) { _, _ in pending = PuzzleState.pending }
    }

    private func subtitle(_ a: AlarmItem) -> String {
        let days = a.weekdays.isEmpty ? "Once"
            : a.weekdays.sorted().map { Calendar.current.shortWeekdaySymbols[$0 - 1] }.joined(separator: " ")
        return "\(a.label) · \(days)\(a.vibrationOnly ? " · vibrate" : "")"
    }
}
