import SwiftUI

struct TaskRowView: View {
    @ObservedObject var task: TaskEntity

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.name ?? "Unnamed Task")
                    .font(.headline)
                    .foregroundColor(.primary)

                if let dueTime = task.dueTime {
                    Text("Due: \(dueTime, formatter: taskTimeFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Toggle("", isOn: $task.isCompleted)
                .labelsHidden()
                .toggleStyle(CheckboxStyle())
                .onChange(of: task.isCompleted) { _ in
                    saveChanges()
                }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray5)))
        .padding(.vertical, 4)
    }

    private var taskTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    private func saveChanges() {
        do {
            try task.managedObjectContext?.save()
        } catch {
            print("Error saving task completion status: \(error.localizedDescription)")
        }
    }
}

struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .green : .blue)
        }
    }
}

struct TaskRowView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let newTask = TaskEntity(context: context)
        newTask.name = "Sample Task"
        newTask.isCompleted = false
        newTask.dueTime = Date()

        return TaskRowView(task: newTask)
    }
}
