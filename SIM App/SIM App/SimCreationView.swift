import SwiftUI

struct SimCreationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var simName: String = ""
    @State private var simGender: String = ""
    @State private var simAge: Int = 18
    @State private var selectedImageIndex = 0
    @State private var isNameValid: Bool = true
    @Environment(\.presentationMode) private var presentationMode
    let simImages = [
        "batman",
        "minion",
        "angrybird",
        "mario",
        "pokeball",
        "ridinghood",
        "spongebob",
        "vader"
    ]

    var body: some View {
        VStack {
            Text("Create New Sim")
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
                .onChange(of: simName) { newValue in
                    isNameValid = !newValue.isEmpty
                }
                .foregroundColor(isNameValid ? .primary : .red)

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
                saveSim()
            }) {
                Text("Create Sim")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(!isNameValid)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button("Back") {
            presentationMode.wrappedValue.dismiss()
        })
    }

    private func saveSim() {
        guard !simName.isEmpty else { return }

        withAnimation {
            let newSim = SimEntity(context: viewContext)
            newSim.id = UUID()
            newSim.name = simName
            newSim.gender = simGender
            newSim.age = Int16(simAge)
            // Assign selected image URL or name to newSim property
            newSim.character = Int16(selectedImageIndex)

            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Error saving new Sim: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func selectNextImage() {
        selectedImageIndex = (selectedImageIndex + 1) % simImages.count
    }

    private func selectPreviousImage() {
        selectedImageIndex = (selectedImageIndex + simImages.count - 1) % simImages.count
    }
}

struct SimCreationView_Previews: PreviewProvider {
    static var previews: some View {
        SimCreationView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
