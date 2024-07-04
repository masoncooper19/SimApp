import Combine
import SwiftUI
import CoreData

class DailyTaskManager: ObservableObject {
    private var timer: AnyCancellable?

    init() {
        startTimer()
    }

    private func startTimer() {
        let now = Date()
        let nextMidnight = Calendar.current.startOfDay(for: now).addingTimeInterval(86400)
        let interval = nextMidnight.timeIntervalSince(now)

        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.resetDailyTasks()
                self?.startTimer() // Schedule next reset
            }
    }

    private func resetDailyTasks() {
        // Fetch all daily tasks and reset their completion status
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<DailyTaskEntity> = DailyTaskEntity.fetchRequest()

        do {
            let tasks = try context.fetch(fetchRequest)
            for task in tasks {
                task.isCompleted = false
            }
            try context.save()
        } catch {
            print("Failed to reset daily tasks: \(error)")
        }
    }
}
