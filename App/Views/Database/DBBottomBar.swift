import SwiftUI

struct DBBottomBar: View {
    @Binding var dbViewType: DBViewType
    
    var body: some View {
        HStack {
            Spacer()
            
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
        }
        .labelStyle(.iconOnly)
        .offset(y:2)
        .onChange(of: dbViewType, {
            Config.setCurrentDBViewType(dbViewType)
        })
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
