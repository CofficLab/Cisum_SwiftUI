import SwiftUI

struct BottomViewType: View {
    @EnvironmentObject var app: AppManager
    
    var body: some View {
        ZStack {
            switch app.dbViewType {
            case .List:
                BottomTile(
                    title: "列表视图",
                    image: "list.bullet",
                    onTap: {
                        app.dbViewType = .Tree
                    })
            case .Tree:
                BottomTile(
                    title: "文件视图",
                    image: "rectangle.3.group.fill",
                    onTap: {
                        app.dbViewType = .List
                    })
            }
        }
        .labelStyle(.iconOnly)
        .onChange(of: app.dbViewType, {
            Config.setCurrentDBViewType(app.dbViewType)
        })
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
