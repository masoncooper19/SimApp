import SwiftUI

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var sim: SimEntity
    @Environment(\.presentationMode) private var presentationMode

    @State private var taskName: String = ""
    @State private var taskTimeToComplete: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Name", text: $taskName)
                    DatePicker("Time to Complete", selection: $taskTimeToComplete, displayedComponents: .date)
                }
                
                Button(action: {
                    saveTask()
                }) {
                    Text("Save Task")
                }
            }
            .navigationTitle("Add Task")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func saveTask() {
        withAnimation {
            let newTask = TaskEntity(context: viewContext)
            newTask.id = UUID()
            newTask.name = taskName
            newTask.timeToComplete = taskTimeToComplete
            newTask.sim = sim

            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let previewSim = SimEntity(context: context)
        previewSim.id = UUID()
        previewSim.name = "Test Sim"
        previewSim.gender = "Male"
        previewSim.age = 30

        return AddTaskView(sim: previewSim).environment(\.managedObjectContext, context)
    }
}
