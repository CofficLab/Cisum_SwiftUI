import OSLog
import SwiftData
import SwiftUI

struct SceneView: View {
    @EnvironmentObject var diskManager: DataManager
    
    @State var select: AppScene = .Music
    
    var body: some View {
        Picker("", selection: $select) {
            ForEach(AppScene.allCases) {
                Text($0.title).tag($0)
            }
        }
        .onAppear {
            self.select = diskManager.appScene
        }
        .onChange(of: select, {
            diskManager.chageScene(select)
        })
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }.modelContainer(Config.getContainer)
}
