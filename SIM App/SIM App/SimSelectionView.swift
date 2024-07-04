import SwiftUI

struct SimSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SimEntity.name, ascending: true)],
        animation: .default)
    private var sims: FetchedResults<SimEntity>
    @State private var showSimCreation = false
    @State private var isEditing = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(sims) { sim in
                        NavigationLink(destination: TaskManagementView(sim: sim)) {
                            Text(sim.name ?? "Unnamed Sim")
                        }
                    }
                    .onDelete(perform: deleteSim)
                }
                .listStyle(InsetGroupedListStyle())
                .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))

                Button(action: {
                    showSimCreation.toggle()
                }) {
                    Text("Create New Sim")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $showSimCreation) {
                    SimCreationView().environment(\.managedObjectContext, viewContext)
                }
            }
            .navigationTitle("Select Sim")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isEditing.toggle() }) {
                        Text(isEditing ? "Done" : "Edit")
                    }
                }
            }
        }
    }

    private func deleteSim(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let simToDelete = sims[index]
                if let tasksToDelete = simToDelete.tasks as? Set<TaskEntity> {
                    for task in tasksToDelete {
                        viewContext.delete(task)
                    }
                }
                viewContext.delete(simToDelete)
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

struct SimSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SimSelectionView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
