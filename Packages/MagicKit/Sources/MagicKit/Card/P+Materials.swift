import SwiftUI

/// 材质卡片预览
struct CardMaterialsPreview: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("材质卡片")
                .font(.headline)
                .withDivider(spacing: 10)

            Text("基础卡片")
                .inCardUltraThin()

            Text("薄材质")
                .inCardThin()

            Text("常规材质")
                .inCardRegular()

            Text("厚材质")
                .inCardThick()
        }
        .padding()
        .infinite()
        .inScrollView()
    }
}

#if DEBUG
    #Preview("Card Materials") {
        CardMaterialsPreview()
            .frame(height: 600)
            .frame(width: 500)
    }
#endif
