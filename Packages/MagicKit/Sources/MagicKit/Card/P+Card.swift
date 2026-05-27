import SwiftUI

/// Card组件的预览和示例
struct CardPreviews: View {
    var body: some View {
        VStack(spacing: 30) {
            // Title
            Text("Magic Card Extensions")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)
                .withDivider(spacing: 10)

            CardMaterialsPreview()
            CardColorsPreview()
            CardComplexPreview()
        }
        .padding()
        .inScrollView()
    }
}

#if DEBUG
    #Preview("Card Extensions") {
        CardPreviews()
            .frame(height: 700)
            .frame(width: 500)
    }
#endif
