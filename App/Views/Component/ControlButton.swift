import OSLog
import SwiftUI

struct ControlButton: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager

    @State private var hovered: Bool = false
    @State private var pressed: Bool = false
    @State private var isButtonTapped = false
    @State private var showTips: Bool = false

    var title: String = "标题"
    var tips: String = ""
    var image: String = "plus"
    var dynamicSize = true
    var onTap: () -> Void = {
        os_log("点击了button")
    }

    var menus: AnyView? = nil

    var body: some View {
        ZStack {
            if dynamicSize == false {
                makeButton()
            } else {
                GeometryReader { geo in
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            makeButton(geo)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    func makeButton(_ geo: GeometryProxy? = nil) -> some View {
        ZStack {
            if let menus = menus {
                Menu(content: {
                    menus
                        .labelStyle(.titleAndIcon)
                }, label: {
                    getImage(geo)
                })
                .menuIndicator(.hidden)
                // 注意测试ButtonStyle对这个操作的影响：
                //  其他App获取焦点
                //  点击本App的button，看看是否有反应
                #if os(macOS)
                .buttonStyle(PlainButtonStyle())
                .foregroundStyle(.primary)
                #endif
            } else {
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
                        title: { Text(title) },
                        icon: {
                            getImage(geo)
                        }
                    )
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
    }

    func getImage(_ geo: GeometryProxy?) -> some View {
        Image(systemName: image)
            .font(getSize(geo))
            .padding(7)
            .background(hovered ? Color.gray.opacity(0.4) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 10.0))
            .onHover(perform: { hovering in
                self.hovered = hovering
            })
            .scaleEffect(pressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: pressed)
    }

    func getSize(_ geo: GeometryProxy?) -> Font {
        if dynamicSize == false {
            return .body
        }

        guard let geo = geo else {
            return .system(size: 24)
        }

        return .system(size: min(geo.size.height, geo.size.width) * 0.45)
    }
}

struct SmartButtonStyle: ButtonStyle {
    @State var hovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(7)
            .background(hovered ? Color.gray.opacity(0.4) : .clear)
            .onHover(perform: { hovering in
                self.hovered = hovering
            })
            .clipShape(RoundedRectangle(cornerRadius: 10.0))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview("Button") {
    VStack {
        ControlButton(title: "菜单", menus: AnyView(VStack {
            Button("1", action: {})
            Button("2", action: {})
        }))
        
        ControlButton(title: "菜单2")
    }
    .frame(height: 300)
    .frame(width: 300)
}

#Preview("App") {
    AppPreview()
}

#Preview("Layout") {
    LayoutView()
}
