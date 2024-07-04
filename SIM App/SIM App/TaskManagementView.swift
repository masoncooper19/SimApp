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
                            TaskListItem(task: task)
                        }
                        .onDelete(perform: deleteTask)
                    }
                }
                
                if !dailyTasks.isEmpty {
                    Section(header: Text("Daily Tasks")) {
                        ForEach(dailyTasks) { task in
                            DailyTaskListItem(task: task)
                        }
                        .onDelete(perform: deleteDailyTask)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())

            if !dailyTasks.isEmpty {
                dailyTaskProgressBar()
                    .padding()
            }

            addButton()
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
    
    private func deleteDailyTask(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let taskToDelete = dailyTasks[index]
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

    private func dailyTaskProgressBar() -> some View {
        VStack {
            Text("Daily Task Progress")
                .font(.headline)
            ProgressView(value: calculateDailyTaskCompletion(), total: Double(dailyTasks.count))
                .progressViewStyle(LinearProgressViewStyle())
                .accentColor(.blue)
        }
    }

    private func addButton() -> some View {
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

    private func calculateDailyTaskCompletion() -> Double {
        let completedTasks = dailyTasks.filter { $0.isCompleted }.count
        return Double(completedTasks)
    }
}

struct TaskListItem: View {
    @ObservedObject var task: TaskEntity
    private let dateFormatter: DateFormatter
    
    init(task: TaskEntity) {
        self.task = task
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "M/d/yy"
    }
    
    var body: some View {
        HStack {
            Text(task.name ?? "")
            Spacer()
            VStack {
                //dateToComplete is for time and timeToComplete is for date
                Text(dateFormatter.string(from: task.timeToComplete ?? Date()))
                    .font(.caption)
                Text(task.dateToComplete ?? Date(), style: .time)
                    .font(.caption)

            }
            CheckboxView(isChecked: Binding(
                get: { task.isCompleted },
                set: { isChecked in
                    withAnimation {
                        task.isCompleted = isChecked
                        try? task.managedObjectContext?.save()
                    }
                }
            ))
        }
    }
}

struct DailyTaskListItem: View {
    @ObservedObject var task: DailyTaskEntity
    
    var body: some View {
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
                        try? task.managedObjectContext?.save()
                    }
                }
            ))
        }
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
