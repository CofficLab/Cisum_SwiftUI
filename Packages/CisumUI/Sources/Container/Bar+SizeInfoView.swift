import SwiftUI

extension MagicContainer {
    var sizeInfoView: some View {
        HStack {
            Spacer()
            if scale != 1.0 {
                // 显示缩放后的实际尺寸和缩放比例
                Label("原始尺寸: \(Int(containerWidth)) x \(Int(containerHeight))", systemImage: "ruler")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text("已缩放到: \(String(format: "%.1f", scale))x")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            } else {
                // 原始尺寸，无缩放
                Label("\(Int(containerWidth)) x \(Int(containerHeight))", systemImage: "ruler")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
        .infinite()
        .background(Color.primary.opacity(0.08))
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
