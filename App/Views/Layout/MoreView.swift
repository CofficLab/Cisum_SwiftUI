import SwiftUI

struct MoreView: View {
    var body: some View {
        TabView {
            DBView()
                .badge(2)
                .tabItem {
                    Label("仓库", systemImage: "music.note.list")
                }

            SettingView()
                .badge("!")
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
        .tabViewStyle(DefaultTabViewStyle())
    }
}

#Preview {
    AppPreview()
}
