import SwiftUI

/// 颜色卡片预览
struct CardColorsPreview: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("颜色卡片")
                .font(.headline)
                .withDivider(spacing: 10)

            Text("蓝色卡片")
                .foregroundColor(.white)
                .inCard(color: .blue)

            Text("红色半透明")
                .inCard(color: .red.opacity(0.8))

            Text("绿色渐变")
                .foregroundColor(.white)
                .inCard(gradient: [.green, .green.opacity(0.6)])
        }
        .padding()
    }
}

#if DEBUG
    #Preview("Card Colors") {
        CardColorsPreview()
            .frame(height: 600)
            .frame(width: 500)
    }
#endif
