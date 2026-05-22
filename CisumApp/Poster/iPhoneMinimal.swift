import CisumUI
import MagicKit
import SwiftUI

struct iPhoneMinimal: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                Group {
                    Text("Cisum")
                        .asPosterTitleForIPhone()

                    Text("极简设计")
                        .asPosterSubTitleForIPhone()
                }
                .cisumVStackCenter()
                .frame(height: geo.size.height * 0.3)

                ZStack {
                    ContentLayout()
                        .hideDetail()
                        .inRootView()
                        .inDemoMode()
                        .frame(width: Config.minWidth + 100)
                        .frame(height: geo.size.height * 0.3)
                        .cisumRoundedLarge()
                        .cisumShadowSm()
                        .scaleEffect(2)
                }
                .frame(height: geo.size.height * 0.7)
            }.cisumHStackCenter()
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("App Store iOS - Minimal - iPhone 5.5") {
    iPhoneMinimal()
        .cisumPreviewContainer(.cisumIPhone55, scale: 0.45)
}

#Preview("App Store iOS - Minimal - iPhone 6.5") {
    iPhoneMinimal()
        .cisumPreviewContainer(.cisumIPhone65, scale: 0.45)
}

#Preview("App Store iOS - Minimal - iPhone 6.9") {
    iPhoneMinimal()
        .cisumPreviewContainer(.cisumIPhone69, scale: 0.45)
}
