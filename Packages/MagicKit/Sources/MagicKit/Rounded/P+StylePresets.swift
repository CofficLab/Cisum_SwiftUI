import SwiftUI

/// 样式预设预览
struct StylePresetsPreview: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Style Presets")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                Text("Card Title")
                    .font(.headline)
                Text("Card Content")
                    .font(.caption)
            }
            .foregroundColor(.white)
            .padding()
            .infiniteWidth()
            .background(Color.blue)
            .cardRounded()

            Text("Button")
                .font(.title3)
                .foregroundColor(.white)
                .padding()
                .infiniteWidth()
                .background(Color.pink)
                .buttonRounded()
        }
        .padding()
        .roundedMedium()
    }
}

#if DEBUG
    #Preview("Style Presets") {
        StylePresetsPreview()
            .frame(height: 600)
    }
#endif
