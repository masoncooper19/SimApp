import SwiftUI

struct SimSelectionView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SimEntity.name, ascending: true)],
        animation: .default)
    private var sims: FetchedResults<SimEntity>
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showAddSim = false

    var body: some View {
        VStack {
            List {
                ForEach(sims) { sim in
                    if let name = sim.name {
                        NavigationLink(destination: TaskManagementView(sim: sim)) {
                            Text(name)
                        }
                    } else {
                        Text("Unknown Sim")
                    }
                }
            }

            Button(action: {
                showAddSim.toggle()
            }) {
                Text("Create New Sim")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .sheet(isPresented: $showAddSim) {
                SimCreationView().environment(\.managedObjectContext, viewContext)
            }
        }
        .navigationTitle("Select Sim")
    }
}

struct SimSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SimSelectionView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
