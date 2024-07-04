import SwiftUI

struct TaskManagementView: View {
    @ObservedObject var sim: SimEntity
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var tasks: FetchedResults<TaskEntity>
    @State private var showAddTask = false

    init(sim: SimEntity) {
        self.sim = sim
        self._tasks = FetchRequest<TaskEntity>(
            sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.timeToComplete, ascending: true)],
            predicate: NSPredicate(format: "sim == %@", sim),
            animation: .default)
    }

    var body: some View {
        VStack {
            List {
                ForEach(tasks) { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.name ?? "")
                                .font(.headline)
                            Text("\(task.timeToComplete?.formattedDate ?? "") at \(task.timeToComplete?.formattedTime ?? "")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
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
            .listStyle(InsetGroupedListStyle())

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
        .navigationTitle("Tasks")
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

extension Date {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
