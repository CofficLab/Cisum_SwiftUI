import SwiftUI

struct DBBottomBar: View {
    @Binding var treeView: Bool
    
    var body: some View {
        HStack {
            Spacer()
            
            ControlButton(
                title: "列表视图",
                image: "list.bullet",
                dynamicSize: false,
                onTap: {
                    self.treeView = false
                })

            ControlButton(
                title: "文件夹视图",
                image: "rectangle.3.group.fill",
                dynamicSize: false,
                onTap: {
                    self.treeView = true
                })
        }
        .labelStyle(.iconOnly)
        .offset(y:2)
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
