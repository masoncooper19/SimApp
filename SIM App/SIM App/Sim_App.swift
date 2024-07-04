import SwiftUI

@main
struct Sim_App: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var dailyTaskManager = DailyTaskManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dailyTaskManager)
        }
    }
}
