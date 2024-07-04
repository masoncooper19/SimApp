import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: SimEntity.entity(),
        sortDescriptors: []
    ) var sims: FetchedResults<SimEntity>
    @State private var selectedSim: SimEntity?
    @State private var showSimList: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if let sim = selectedSim {
                    TasksView(sim: sim)
                } else {
                    Text("Create a new Sim to get started")
                        .padding()
                }

                Button(action: {
                    showSimList = true
                }) {
                    Text("Change Sim")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Sim Tasks")
            .sheet(isPresented: $showSimList) {
                SimListView(selectedSim: $selectedSim)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
