import SwiftUI

struct SimDetailView: View {
    @ObservedObject var sim: SimEntity
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
        VStack(spacing: 20) {  
            
            Image(simImages[Int(sim.character)])
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                .padding(.horizontal)
            
            Text(sim.name ?? "Unnamed Sim")
                .font(.largeTitle)
                .fontWeight(.bold)

            HStack {
                Text("Gender:")
                    .font(.headline)
                Spacer()
                Text(sim.gender ?? "Unknown")
                    .font(.body)
            }
            .padding(.horizontal)

            HStack {
                Text("Age:")
                    .font(.headline)
                Spacer()
                Text("\(sim.age)")
                    .font(.body)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SimDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let sampleSim = SimEntity(context: context)
        sampleSim.name = "John Doe"
        sampleSim.gender = "Male"
        sampleSim.age = 25
        
        return NavigationView {
            SimDetailView(sim: sampleSim)
        }
    }
}
