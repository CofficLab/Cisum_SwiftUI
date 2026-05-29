import SwiftUI

extension MagicContainer {
    @ViewBuilder
    var xcodeIconButton: some View {
        let containerSize = CGSize(width: containerWidth, height: containerHeight)
        if containerSize.isSquare {
            Button(action: captureXcodeIcons) {
                HStack {
                    Image(systemName: "hammer")
                    Text("Xcode 图标")
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview("Xcode Icon Generator") {
    Image.star
        .resizable()
        .scaledToFit()
        .infinite()
        .inBackgroundMint()
        .inMagicContainer(CGSize(width: 1024, height: 1024), scale: 0.6)
}
