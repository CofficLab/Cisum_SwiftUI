import SwiftUI

public struct iPadDevice: SuperScreen {
    public var horizon: Bool = false

    public init(horizon: Bool = false) {
        self.horizon = horizon
    }

    public var screenWidth: CGFloat {
        horizon ? 2275 : 1488
    }

    public var screenHeight: CGFloat {
        horizon ? 1500 : 2266
    }

    public var deviceImageName: String {
        "iPad mini - Starlight - Portrait"
    }

    public var landscapeImageName: String? {
        "iPad mini - Starlight - Landscape"
    }

    public var screenOffsetX: CGFloat {
        0
    }

    public var screenOffsetY: CGFloat {
        0
    }
}

public struct iPadScreen<Content>: View where Content: View {
    private let content: Content
    public var horizon = false

    public init(horizon: Bool = false, @ViewBuilder content: () -> Content) {
        self.horizon = horizon
        self.content = content()
    }

    public var body: some View {
        ScreenBase(device: iPadDevice(horizon: horizon), horizon: horizon) {
            content
        }
    }
}

// MARK: - Preview

#Preview("iPad - Portrait") {
    HStack {
        Spacer()
        VStack {
            Spacer()
            Image(systemName: "ipad")
                .font(.system(size: 250))
                .foregroundColor(.blue)

            Text("iPad 预览")
                .font(.system(size: 120))
                .fontWeight(.bold)

            Text("竖屏模式")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Spacer()
        }
        Spacer()
    }
    .padding(25)
    .background(.orange.opacity(0.2))
    .inIPadScreen()
}

#Preview("iPad - Landscape") {
    VStack {
        Spacer()
        HStack {
            Spacer()
            Image(systemName: "ipad")
                .font(.system(size: 200))
                .foregroundColor(.green)

            VStack(alignment: .leading) {
                Text("iPad 横屏")
                    .font(.system(size: 100))
                    .fontWeight(.bold)

                Text("横屏模式")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        Spacer()
    }
    .padding(20)
    .background(.green.opacity(0.2))
    .inIPadScreen(horizon: true)
}
