import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            SimSelectionView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
