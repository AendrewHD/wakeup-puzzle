import SwiftUI

@main
struct WakeUpApp: App {
    @StateObject private var store = AlarmStore()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(store)
        }
    }
}
