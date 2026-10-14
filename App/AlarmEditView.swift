import SwiftUI

struct AlarmEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var item: AlarmItem
    @State private var time: Date
    let onSave: (AlarmItem) -> Void

    init(item: AlarmItem, onSave: @escaping (AlarmItem) -> Void) {
        _item = State(initialValue: item)
        _time = State(initialValue: Calendar.current.date(
            bySettingHour: item.hour, minute: item.minute, second: 0, of: Date()) ?? Date())
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                TextField("Label", text: $item.label)
                Section("Repeat (none = once)") {
                    HStack {
                        ForEach(1...7, id: \.self) { d in
                            let on = item.weekdays.contains(d)
                            Text(String(Calendar.current.veryShortWeekdaySymbols[d - 1]))
                                .frame(width: 36, height: 36)
                                .background(on ? Color.orange : Color.gray.opacity(0.2), in: Circle())
                                .foregroundStyle(on ? .white : .primary)
                                .onTapGesture {
                                    if on { item.weekdays.removeAll { $0 == d } } else { item.weekdays.append(d) }
                                }
                        }
                    }
                }
                Toggle("Vibration only (silent sound)", isOn: $item.vibrationOnly)
            }
            .navigationTitle("Alarm")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let c = Calendar.current.dateComponents([.hour, .minute], from: time)
                        item.hour = c.hour ?? 7
                        item.minute = c.minute ?? 0
                        item.enabled = true
                        onSave(item)
                        dismiss()
                    }
                }
            }
        }
    }
}
