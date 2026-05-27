import SwiftUI

public struct iPhoneDevice: SuperScreen {
    public var horizon: Bool = false

    public init(horizon: Bool = false) {
        self.horizon = horizon
    }

    public var screenWidth: CGFloat {
        horizon ? 2600 : 1165
    }

    public var screenHeight: CGFloat {
        horizon ? 1200 : 2528
    }

    public var deviceImageName: String {
        "iPhone 14 - Midnight - Portrait"
    }

    public var landscapeImageName: String? {
        "iPhone 14 - Midnight - Landscape"
    }

    public var screenOffsetX: CGFloat {
        0
    }

    public var screenOffsetY: CGFloat {
        0
    }
}

public struct iPhoneScreen<Content>: View where Content: View {
    private let content: Content
    public var horizon = false

    public init(horizon: Bool = false, @ViewBuilder content: () -> Content) {
        self.horizon = horizon
        self.content = content()
    }

    public var body: some View {
        ScreenBase(device: iPhoneDevice(horizon: horizon), horizon: horizon) {
            content
        }
    }
}

// MARK: - Preview

#Preview("iPhone - Portrait") {
    HStack {
        Spacer()
        VStack {
            Spacer()
            Image(systemName: "iphone")
                .font(.system(size: 200))
                .foregroundColor(.blue)

            Text("iPhone 预览")
                .font(.system(size: 100))
                .fontWeight(.bold)

            Text("竖屏模式")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Spacer()
        }
        Spacer()
    }
    .padding(20)
    .background(.orange.opacity(0.2))
    .inIPhoneScreen()
}

#Preview("iPhone - Landscape") {
    HStack {
        Spacer()
        Image(systemName: "iphone")
            .font(.system(size: 150))
            .foregroundColor(.green)

        VStack(alignment: .leading) {
            Spacer()
            Text("iPhone 横屏")
                .font(.system(size: 80))
                .fontWeight(.bold)

            Text("横屏模式")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Spacer()
        }
        Spacer()
    }
    .padding(15)
    .background(.green.opacity(0.2))
    .inIPhoneScreen(horizon: true)
}
