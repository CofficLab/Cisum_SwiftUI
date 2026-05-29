import SwiftUI

public struct iMacDevice: SuperScreen {
    public var screenWidth: CGFloat {
        5120
    }
    
    public var screenHeight: CGFloat {
        2890
    }
    
    public var deviceImageName: String {
        "iMac 27\" - Silver"
    }
    
    public var landscapeImageName: String? {
        nil
    }
    
    public var screenOffsetX: CGFloat {
        0
    }
    
    public var screenOffsetY: CGFloat {
        -568
    }
}

public struct iMacScreen<Content>: View where Content: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ScreenBase(device: iMacDevice(), horizon: false) {
            content
        }
    }
}

// MARK: - Preview

#Preview("iMac - Basic") {
    HStack {
        Spacer()
        VStack {
            Spacer()
            Image(systemName: "desktopcomputer")
                .font(.system(size: 400))
                .foregroundColor(.blue)
            
            Text("iMac 预览")
                .font(.system(size: 300))
                .fontWeight(.bold)
            Spacer()
        }
        Spacer()
    }
    .padding(40)
    .background(.orange.opacity(0.2))
    .inIMacScreen()
    .frame(height: 500)
    .frame(width: 600)
}
