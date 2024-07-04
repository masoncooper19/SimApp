import SwiftUI

struct EditSimView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var sim: SimEntity
    
    @State private var simName: String
    @State private var simGender: String
    @State private var simAge: Int
    @State private var selectedImageIndex: Int
    
    let simImages = [
        "batman",
        "minion",
        "angrybird",
        "ridinghood",
        "spongebob",
        "vader"
    ]

    init(sim: SimEntity) {
        self.sim = sim
        self._simName = State(initialValue: sim.name ?? "")
        self._simGender = State(initialValue: sim.gender ?? "")
        self._simAge = State(initialValue: Int(sim.age))
        self._selectedImageIndex = State(initialValue: Int(sim.character))
    }

    var body: some View {
        VStack {
            Text("Edit Sim")
                .font(.title)
                .padding()

            // Image selection with left and right arrows
            HStack {
                Button(action: {
                    // Go to previous image (looping)
                    if selectedImageIndex > 0 {
                        selectedImageIndex -= 1
                    } else {
                        selectedImageIndex = simImages.count - 1
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .font(.title)
                }

                Image(simImages[selectedImageIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))

                Button(action: {
                    // Go to next image (looping)
                    selectedImageIndex = (selectedImageIndex + 1) % simImages.count
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .font(.title)
                }
            }
            .padding()

            TextField("Enter Sim Name", text: $simName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Picker(selection: $simGender, label: Text("Gender")) {
                Text("Male").tag("Male")
                Text("Female").tag("Female")
                Text("Other").tag("Other")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Stepper(value: $simAge, in: 0...120) {
                Text("Age: \(simAge)")
            }
            .padding()

            Button(action: {
                saveChanges()
            }) {
                Text("Save Changes")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        })
        .onDisappear {
            viewContext.rollback() // Rollback changes if navigating away without saving
        }
    }

    private func saveChanges() {
        guard !simName.isEmpty else { return }
        
        withAnimation {
            sim.name = simName
            sim.gender = simGender
            sim.age = Int16(simAge)
            sim.character = Int16(selectedImageIndex)
            
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Error saving changes to Sim: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct EditSimView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let sampleSim = SimEntity(context: context)
        sampleSim.name = "John Doe"
        sampleSim.gender = "Male"
        sampleSim.age = 25
        
        return NavigationView {
            EditSimView(sim: sampleSim)
                .environment(\.managedObjectContext, context)
        }
    }
}
