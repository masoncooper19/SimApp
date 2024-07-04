import SwiftUI

struct SimListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: SimEntity.entity(),
        sortDescriptors: []
    ) var sims: FetchedResults<SimEntity>
    @Binding var selectedSim: SimEntity?
    @State private var showCreateSimView: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(sims, id: \.self) { sim in
                        Button(action: {
                            selectedSim = sim
                            showCreateSimView = false
                        }) {
                            Text(sim.name ?? "Unnamed Sim")
                        }
                    }
                }

                Button(action: {
                    showCreateSimView = true
                }) {
                    Text("Create New Sim")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Select a Sim")
            .sheet(isPresented: $showCreateSimView) {
                CreateSimView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

struct SimListView_Previews: PreviewProvider {
    static var previews: some View {
        SimListView(selectedSim: .constant(nil))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
