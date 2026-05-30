import SwiftUI

extension MagicContainer {
    var screenshotButton: some View {
        Button(action: captureView) {
            HStack {
                Image(systemName: "camera")
                Text("截图")
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.bordered)
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
