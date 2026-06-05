import PluginRegistry
import SwiftUI

struct iPhoneICloud: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                Group {
                    Text("Cisum")
                        .asPosterTitleForIPhone()

                    Text("完美支持 iCloud")
                        .asPosterSubTitleForIPhone()
                }
                .cisumVStackCenter()
                .frame(height: geo.size.height * 0.3)

                ContentLayout()
                    .hideDetail()
                    .inRootView()
                    .inDemoMode()
                    .inDownloadingMode()
                    .frame(width: Config.minWidth + 100)
                    .frame(height: geo.size.height * 0.3)
                    .clipped()
                    .cisumRoundedLarge()
                    .cisumShadowSm()
                    .scaleEffect(2)
                    .frame(height: geo.size.height * 0.7)
            }.cisumHStackCenter()
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("App Store iOS - iCloud - iPhone 5.5") {
    iPhoneICloud()
        .cisumPreviewContainer(.cisumIPhone55, scale: 0.45)
}

#Preview("App Store iOS - iCloud - iPhone 6.5") {
    iPhoneICloud()
        .cisumPreviewContainer(.cisumIPhone65, scale: 0.45)
}

#Preview("App Store iOS - iCloud - iPhone 6.9") {
    iPhoneICloud()
        .cisumPreviewContainer(.cisumIPhone69, scale: 0.45)
}
