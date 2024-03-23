import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
            .environmentObject(AudioManager.shared)
            .environmentObject(DatabaseManager.shared)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
