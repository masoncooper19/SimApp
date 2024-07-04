import SwiftUI

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var sim: SimEntity
    
    @State private var taskName: String = ""
    @State private var selectedDate = Date()

    var body: some View {
        NavigationView {
            VStack {
                TextField("Task Name", text: $taskName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                DatePicker("Select Date and Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()

                Button(action: {
                    saveTask()
                }) {
                    Text("Save Task")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
            .navigationTitle("Add Task")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func saveTask() {
        guard !taskName.isEmpty else {
            // Show an alert or message to prompt user to enter a task name
            return
        }

        let newTask = TaskEntity(context: viewContext)
        newTask.id = UUID()
        newTask.name = taskName
        newTask.timeToComplete = selectedDate
        newTask.isCompleted = false
        newTask.sim = sim

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Error saving new Task: \(nsError), \(nsError.userInfo)")
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
