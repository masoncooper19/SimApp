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
                        if let taskName = task.name {
                            Text(taskName)
                        } else {
                            Text("Unknown Task")
                        }
                        Spacer()
                        Text(task.timeToComplete ?? Date(), style: .date)
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
        .navigationBarItems(trailing: NavigationLink(destination: SimSelectionView()) {
            Text("Change Sim")
        })
    }

    private func deleteTask(offsets: IndexSet) {
        withAnimation {
            offsets.map { tasks[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

struct TaskManagementView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let previewSim = SimEntity(context: context)
        previewSim.id = UUID()
        previewSim.name = "Test Sim"
        previewSim.gender = "Male"
        previewSim.age = 30
        
        return TaskManagementView(sim: previewSim).environment(\.managedObjectContext, context)
    }
}
