import SwiftUI

struct DBEmptyView: View {
    @EnvironmentObject var appManager: AppManager
    
    var supportedFormats: String {
        AppConfig.supportedExtensions.joined(separator: ",")
    }

    var body: some View {
        CardView(background: BackgroundView.type3) {
            VStack {
                #if os(iOS)
                    Text("仓库中没有音乐文件")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 20)

                BtnAdd().buttonStyle(.bordered).foregroundStyle(.white)
                #endif

                #if os(macOS)
                VStack(spacing: 20) {
                    HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.yellow)
                            Text("将音乐文件拖到这里")
                                .font(.title3)
                                .foregroundStyle(.white)
                    }
                    Text("支持的格式：\(supportedFormats)")
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
        .frame(width: 300, height: 300)
        .background(BackgroundView.type1)
}

#Preview {
    RootView {
        DBView()
    }.modelContainer(AppConfig.getContainer())
}
