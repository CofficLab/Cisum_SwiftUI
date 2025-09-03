import SwiftUI

struct TopView: View {
    @EnvironmentObject var man: PlayMan
    @EnvironmentObject var p: PluginProvider

    var asset: URL? { man.currentURL }

    var body: some View {
        if Config.isNotDesktop {
            HStack {
                if p.groupPlugins.count > 1 {
                    BtnScene()
                }
                
                Spacer()
                if let asset = asset {
                    HStack {
                        man.makeLikeButtonView()
                        if Config.isDesktop {
                            asset.makeOpenButton()
                        }
                    }
                }
            }
            .padding(.horizontal)
            .labelStyle(.iconOnly)
        } else {
            EmptyView()
        }
    }
}

#if os(macOS)
#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif

