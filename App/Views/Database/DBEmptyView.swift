import SwiftUI

struct DBEmptyView: View {
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        CardView(background: BackgroundView.type3) {
            VStack {
                #if os(iOS)
                    Text("仓库中没有音乐文件")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 20)

                ButtonAdd().buttonStyle(.bordered).foregroundStyle(.white)
                #endif

                #if os(macOS)
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.brown)
                        Text("将音乐文件拖到这里")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                #endif
            }
        }
    }
}

#Preview {
    DBEmptyView()
}

#Preview {
    RootView {
        DBView()
    }
}
