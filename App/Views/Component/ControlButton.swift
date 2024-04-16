import OSLog
import SwiftUI

struct ControlButton: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager

    @State private var hovered: Bool = false
    @State private var isButtonTapped = false
    @State private var showTips: Bool = false

    var title: String = "标题"
    var size: Double = 48
    var tips: String = ""
    var systemImage: String = "home"
    var dynamicSize = true
    var onTap: () -> Void = {
        os_log("点击了button")
    }

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
        .background(.yellow.opacity(0))
    }
    
    func makeButton(_ geo: GeometryProxy? = nil) -> some View {
        Button(action: {
            withAnimation(.default) {
                onTap()
            }
        }, label: {
            Label(title, systemImage: systemImage)
                .font(.system(size: getSize(geo)))
        })
//                    .popover(isPresented: $showTips, content: {
//                        Text(tips).padding()
//                    })
        .buttonStyle(MyButtonStyle())
        .background(hovered ? Color.gray.opacity(0.4) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
        .onHover(perform: { hovering in
            withAnimation(.easeInOut) {
                hovered = hovering
                showTips = tips.count > 0 && hovered
            }
        })
    }

    func getSize(_ geo: GeometryProxy?) -> Double {
        guard let geo = geo else {
            return 24
        }
        
        return min(geo.size.height, geo.size.width) * 0.45
    }
}

struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(7)
            .background(configuration.isPressed ? Color.gray.opacity(0.5) : .clear)
            .foregroundColor(.white)
//            .cornerRadius(10)
    }
}

#Preview("App") {
    AppPreview()
}

#Preview("Layout") {
    LayoutView()
}
