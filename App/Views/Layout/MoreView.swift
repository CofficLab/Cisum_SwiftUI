import SwiftUI

struct MoreView: View {
    var body: some View {
        TabView {
            DBView()
                .tabItem {
                    Label("仓库", systemImage: "music.note.list")
                }

            if AppConfig.debug {
                SettingView()
                    .tabItem {
                        Label("设置", systemImage: "gear")
                    }
            }
            
            BuyView()
                .tabItem {
                    Label("商店", systemImage: "crown")
                }
        }
        .padding(.top)
        .background(.background)
        .tabViewStyle(DefaultTabViewStyle())
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
