import OSLog
import SwiftData
import SwiftUI

struct SceneView: View {
    @EnvironmentObject var dataManager: DataManager

    @State var select: DiskScene = .Music
    @State var showSheet: Bool = false

    var body: some View {
        select.icon
            .onTapGesture {
                showSheet = true
            }
            .sheet(isPresented: $showSheet, content: {
                Scenes(selection: $select, isPreseted: $showSheet)
            })
            .onAppear {
                self.select = dataManager.appScene
            }
            .onChange(of: select,{
                try? dataManager.chageScene(select)
                showSheet = false
            })
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}
