import OSLog
import SwiftUI

struct ControlButton: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager

    @State private var hovered: Bool = false
    @State private var isButtonTapped = false

    var title: String = "标题"
    var size: Double = 36
    var systemImage: String = "home"
    var onTap: () -> Void = {
        os_log("点击了button")
    }

    var body: some View {
        Button(action: {
            withAnimation(.default) {
                onTap()
            }
        }, label: {
            Label(title, systemImage: systemImage)
                .font(.system(size: size))
        })
        .buttonStyle(MyButtonStyle())
        .background(hovered ? Color.gray.opacity(0.4) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
        .onHover(perform: { hovering in
            withAnimation(.easeInOut) {
                hovered = hovering
            }
        })
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

#Preview {
    RootView {
        ContentView()
    }
}

#Preview {
    RootView {
        VStack {
            HStack {
                BtnPrev()
                BtnToggle()
                BtnNext()
            }

            HStack {
                BtnToggleDB()
                BtnMode()
            }
        }
    }
}
