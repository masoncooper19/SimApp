import SwiftUI

@main
struct Sim_App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            CreateSimView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
