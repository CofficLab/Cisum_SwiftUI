import OSLog
import SwiftData
import SwiftUI

struct SceneView: View {
    @State var select: AppScene = .Music
    
    var body: some View {
        Picker("", selection: $select) {
            ForEach(AppScene.allCases) {
                Text($0.name).tag($0)
            }
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }.modelContainer(Config.getContainer)
}
