import OSLog
import SwiftData
import SwiftUI

struct SceneView: View {
  @EnvironmentObject var dataManager: DataManager

  @State var select: DiskScene = .Music

  var body: some View {
    Picker("", selection: $select) {
      ForEach(DiskScene.allCases) {
        Text($0.title).tag($0)
      }
    }
    .onAppear {
      self.select = dataManager.appScene
    }
    .onChange(
      of: select,
      {
        dataManager.chageScene(select)
      })
  }
}

#Preview("APP") {
  RootView {
    ContentView()
  }.modelContainer(Config.getContainer)
}
