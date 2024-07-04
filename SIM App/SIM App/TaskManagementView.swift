import SwiftUI

struct TaskManagementView: View {
    @ObservedObject var sim: SimEntity
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var tasks: FetchedResults<TaskEntity>
    @FetchRequest private var dailyTasks: FetchedResults<DailyTaskEntity>
    @State private var showAddTask = false

    init(sim: SimEntity) {
        self.sim = sim
        self._tasks = FetchRequest<TaskEntity>(
            sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.timeToComplete, ascending: true)],
            predicate: NSPredicate(format: "sim == %@", sim),
            animation: .default)
        self._dailyTasks = FetchRequest<DailyTaskEntity>(
            sortDescriptors: [NSSortDescriptor(keyPath: \DailyTaskEntity.time, ascending: true)],
            predicate: NSPredicate(format: "sim == %@", sim),
            animation: .default)
    }

    var body: some View {
        VStack {
            List {
                if !tasks.isEmpty {
                    Section(header: Text("Tasks")) {
                        ForEach(tasks) { task in
                            HStack {
                                Text(task.name ?? "")
                                Spacer()
                                VStack {
                                    Text(task.timeToComplete ?? Date(), style: .date)
                                        .font(.caption)
                                    Text(task.dateToComplete ?? Date(), style: .time)
                                        .font(.caption)
                                }
                                CheckboxView(isChecked: Binding(
                                    get: { task.isCompleted },
                                    set: { isChecked in
                                        withAnimation {
                                            task.isCompleted = isChecked
                                            try? viewContext.save()
                                        }
                                    }
                                ))
                            }
                        }
                        .onDelete(perform: deleteTask)
                    }
                }
                
                if !dailyTasks.isEmpty {
                    Section(header: Text("Daily Tasks")) {
                        ForEach(dailyTasks) { task in
                            HStack {
                                Text(task.name ?? "")
                                Spacer()
                                Text(task.time ?? Date(), style: .time)
                                    .font(.caption)
                                CheckboxView(isChecked: Binding(
                                    get: { task.isCompleted },
                                    set: { isChecked in
                                        withAnimation {
                                            task.isCompleted = isChecked
                                            try? viewContext.save()
                                        }
                                    }
                                ))
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())

            if !dailyTasks.isEmpty {
                ProgressView(value: calculateDailyTaskCompletion(), total: Double(dailyTasks.count))
                    .padding()
            }

            Button(action: {
                showAddTask.toggle()
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
            }
            .padding()
            .sheet(isPresented: $showAddTask) {
                AddTaskView(sim: sim).environment(\.managedObjectContext, viewContext)
            }
        }
        .navigationTitle("Reminders")
        .navigationBarItems(trailing: NavigationLink(destination: SimDetailView(sim: sim)) {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
                .foregroundColor(.blue)
        })
    }

    private func deleteTask(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let taskToDelete = tasks[index]
                viewContext.delete(taskToDelete)
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func calculateDailyTaskCompletion() -> Double {
        let completedTasks = dailyTasks.filter { $0.isCompleted }.count
        return Double(completedTasks)
    }
}

struct TaskManagementView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let sampleSim = SimEntity(context: context)
        sampleSim.name = "John Doe"
        sampleSim.gender = "Male"
        sampleSim.age = 25
        
        return NavigationView {
            TaskManagementView(sim: sampleSim).environment(\.managedObjectContext, context)
        }
    }
}
