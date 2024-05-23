import SwiftUI

struct MoreView: View {
    var body: some View {
        TabView {
            DBView()
                .tabItem {
                    Label("仓库", systemImage: "music.note.list")
                }

            SettingView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
            
            BuyView()
                .tabItem {
                    Label("商店", systemImage: "crown")
                }
                .environmentObject(StoreManager())
        }
        .background(.background)
        .tabViewStyle(DefaultTabViewStyle())
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
