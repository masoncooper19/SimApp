import SwiftUI

struct CreateSimView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var simName: String = ""
    @State private var isSimCreated: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter Sim Name", text: $simName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray5)))
                    .padding()

                Button(action: {
                    saveNewSim()
                }) {
                    Text("Create")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                Spacer()
            }
            .navigationTitle("Create New Sim")
        }
    }

    private func saveNewSim() {
        guard !simName.isEmpty else { return }

        let newSim = SimEntity(context: viewContext)
        newSim.id = UUID()
        newSim.name = simName

        do {
            try viewContext.save()
            isSimCreated = true
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct CreateSimView_Previews: PreviewProvider {
    static var previews: some View {
        CreateSimView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
