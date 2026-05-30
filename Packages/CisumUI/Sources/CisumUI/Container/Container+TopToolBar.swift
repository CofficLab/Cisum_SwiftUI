import SwiftUI

extension MagicContainer {
    var topToolBar: some View {
        GeometryReader { proxy in
            let height = proxy.size.height
            VStack(spacing: 0) {
                // Top row
                HStack(spacing: 4) {
                    Spacer()

                    xcodeIconButton

                    macAppStoreButton

                    iOSAppStoreButton

                    Spacer()
                }
                .padding(.horizontal)
                .frame(height: height * 0.7)
                .frame(maxWidth: .infinity)

                // Bottom
                sizeInfoView
                    .frame(height: height * 0.3)
                    .frame(maxWidth: .infinity)
            }
            .infinite()
            .background(Color.secondary.opacity(0.1))
        }
        .frame(height: toolBarHeight)
        .infiniteWidth()
    }
}

#Preview("iMac 27 - 20%") {
    GeometryReader { geo in
        Text("Hello, World!")
            .font(.system(size: geo.size.width * 0.1))
            .magicCentered()
            .background(.orange.opacity(0.3))
    }
    .inMagicContainer(.iMac27, scale: 0.2)
}

#Preview("iMac 27 - 10%") {
    GeometryReader { geo in
        Text("Hello, World!")
            .font(.system(size: geo.size.width * 0.1))
            .magicCentered()
            .background(.orange.opacity(0.3))
    }
    .inMagicContainer(.iMac27, scale: 0.1)
}
