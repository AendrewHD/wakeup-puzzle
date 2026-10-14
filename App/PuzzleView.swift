import SwiftUI

/// Day 1: math puzzle only. More puzzle types and the eyes-open face check follow on later days.
struct PuzzleView: View {
    @State private var a = 0
    @State private var b = 0
    @State private var c = 0
    @State private var answer = ""
    @State private var solved = 0
    @State private var wrong = false
    @FocusState private var focused: Bool
    private let needed = 3

    var body: some View {
        VStack(spacing: 24) {
            Text("Solve \(needed - solved) more to stop the alarm")
                .font(.headline).foregroundStyle(.secondary)
            Text("\(a) × \(b) + \(c)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
            TextField("Answer", text: $answer)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title)
                .textFieldStyle(.roundedBorder)
                .frame(width: 180)
                .focused($focused)
            if wrong { Text("Wrong, try again").foregroundStyle(.red) }
            Button("Check", action: check)
                .buttonStyle(.borderedProminent).controlSize(.large)
        }
        .padding()
        .onAppear { next(); focused = true }
    }

    private func next() {
        a = Int.random(in: 12...49)
        b = Int.random(in: 3...9)
        c = Int.random(in: 10...99)
        answer = ""
        wrong = false
    }

    private func check() {
        if Int(answer) == a * b + c {
            solved += 1
            if solved >= needed { PuzzleState.complete() } else { next() }
        } else {
            wrong = true
            answer = ""
        }
    }
}
