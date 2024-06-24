import SwiftUI

struct BottomBar: View {
    @Binding var dbViewType: DBViewType
    @EnvironmentObject var diskManager: DiskManager

    var body: some View {
        HStack {
            ControlButton(
                title: "列表视图",
                image: "list.bullet",
                dynamicSize: false,
                onTap: {
                    self.dbViewType = .List
                })

            ControlButton(
                title: "文件夹视图",
                image: "rectangle.3.group.fill",
                dynamicSize: false,
                onTap: {
                    self.dbViewType = .Tree
                })
            Spacer()

            CopyState()
        }
        .background(.bar)
        .labelStyle(.iconOnly)
        .offset(y: 2)
        .onChange(of: dbViewType, {
            Config.setCurrentDBViewType(dbViewType)
        })
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
