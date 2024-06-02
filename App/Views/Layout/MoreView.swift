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
