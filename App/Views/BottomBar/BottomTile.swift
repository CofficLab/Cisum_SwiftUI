import OSLog
import SwiftUI

struct BottomTile: View {
    @EnvironmentObject var appManager: AppManager

    @State private var hovered: Bool = false
    @State private var pressed: Bool = false
    @State private var isButtonTapped = false
    @State private var showTips: Bool = false

    var title: String = "标题"
    var tips: String = ""
    var image: String = "plus"
    var onTap: () -> Void = {
        os_log("点击了button")
    }

    var body: some View {
        Button(action: {
            withAnimation(.default) {
                self.pressed = true
                onTap()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.pressed = false
                }
            }
        }, label: {
            Label(
                title: {
                    Text(title)
                },
                icon: {
                    Image(systemName: image)
                        .frame(width: 5)
                        .scaleEffect(pressed ? 1.2 : 1)
                        .animation(.easeOut(duration: 0.2), value: pressed)
                        
                }
            )
            .frame(maxHeight: .infinity)
            .padding(.horizontal)
            .background(hovered ? Color.yellow.opacity(0.5) : .clear)
            .onHover(perform: { hovering in
                self.hovered = hovering
            })
        })
        
        // 注意测试ButtonStyle对这个操作的影响：
        //  其他App获取焦点
        //  点击本App的button，看看是否有反应
        #if os(macOS)
        .buttonStyle(LinkButtonStyle())
        .foregroundStyle(.primary)
        #endif
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
