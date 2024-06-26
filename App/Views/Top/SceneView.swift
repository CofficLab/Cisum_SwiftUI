import OSLog
import SwiftData
import SwiftUI

struct SceneView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var app: AppManager

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
                setDBViewType()
            }
            .onChange(of: select,{
                try? dataManager.chageScene(select)
                showSheet = false
                
                setDBViewType()
            })
    }
    
    func setDBViewType() {
        switch select {
        case .Music:
            app.dbViewType = .List
        case .AudiosBook:
            app.dbViewType = .Tree
        case .AudiosKids:
            app.dbViewType = .Tree
        case .VideosKids:
            app.dbViewType = .Tree
        case .Videos:
            app.dbViewType = .Tree
        }
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}
