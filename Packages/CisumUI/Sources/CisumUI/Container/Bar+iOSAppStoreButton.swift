import SwiftUI

extension MagicContainer {
    @ViewBuilder
    var iOSAppStoreButton: some View {
        let containerSize = CGSize(width: containerWidth, height: containerHeight)
        if containerSize.isPortrait {
            Button(action: captureAppStoreView) {
                HStack {
                    Image(systemName: "camera.aperture")
                    Text("iOS App Store 截图")
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview("iPhone") {
    GeometryReader { geo in
        Text("Hello, World!")
            .font(.system(size: geo.size.width * 0.1))
            .magicCentered()
            .background(.orange.opacity(0.3))
    }
    .inMagicContainer(.iPhone, scale: 0.4)
}

#Preview("iPhoneSE") {
    GeometryReader { geo in
        Text("Hello, World!")
            .font(.system(size: geo.size.width * 0.1))
            .magicCentered()
            .background(.orange.opacity(0.3))
    }
    .inMagicContainer(.iPhoneSE, scale: 0.7)
}

#Preview("iPhone 6.5\"") {
    GeometryReader { geo in
        Text("Hello, World!")
            .font(.system(size: geo.size.width * 0.1))
            .magicCentered()
            .background(.orange.opacity(0.3))
    }
    .inMagicContainer(.iPhone65, scale: 0.4)
}
