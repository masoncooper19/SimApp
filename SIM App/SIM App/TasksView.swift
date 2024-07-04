import SwiftUI

struct TasksView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var sim: SimEntity

    @State private var newTaskName: String = ""
    @State private var newTaskDueTime: Date = Date()
    
    var body: some View {
        VStack {
            HStack {
                TextField("New Task", text: $newTaskName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                DatePicker("Due Time", selection: $newTaskDueTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(DefaultDatePickerStyle())
                    .padding()
                    .labelsHidden()

                Button(action: {
                    addTask()
                    newTaskName = ""
                    newTaskDueTime = Date()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .padding()
                        .foregroundColor(.blue)
                }
                .disabled(newTaskName.isEmpty)
            }
            .padding(.bottom)

            Divider()
            
            List {
                ForEach(Array(sim.tasks as? Set<TaskEntity> ?? []), id: \.self) { task in
                    TaskRowView(task: task)
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let task = Array(sim.tasks as? Set<TaskEntity> ?? [])[index]
                        viewContext.delete(task)
                        do {
                            try viewContext.save()
                        } catch {
                            print("Error deleting task: \(error)")
                        }
                    }
                }
            }
        }
        .navigationTitle("\(sim.name ?? "Sim")'s Tasks")
    }
    
    private func addTask() {
        let newTask = TaskEntity(context: viewContext)
        newTask.id = UUID()
        newTask.name = newTaskName
        newTask.isCompleted = false
        newTask.dueTime = Date()
        newTask.sim = sim
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving new task: \(error)")
        }
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let newSim = SimEntity(context: context)
        newSim.name = "Test Sim"

        return TasksView(sim: newSim)
            .environment(\.managedObjectContext, context)
    }
}
