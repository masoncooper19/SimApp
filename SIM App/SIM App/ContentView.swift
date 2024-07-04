import SwiftUI

struct ContentView: View {
    var body: some View {
        SimSelectionView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SimSelectionView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
