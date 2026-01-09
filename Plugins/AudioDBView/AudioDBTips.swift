import MagicBackground
import MagicCore
import SwiftUI

struct AudioDBTips: View {
    enum Variant {
        case empty
        case loading
    }

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var audioManager: AudioProvider
    var variant: Variant = .empty

    var supportedFormats: String {
        Config.supportedExtensions.joined(separator: ",")
    }

    var body: some View {
        MagicCard(background: MagicBackground.mountainStream.opacity(0.9)) {
            VStack {
                switch variant {
                case .empty:
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.yellow)
                            Text(Config.isDesktop ? "将音乐文件拖到这里可添加" : "歌曲仓库为空")
                                .font(.title3)
                                .foregroundStyle(.white)
                        }
                        Text("支持的格式：\(supportedFormats)")
                            .font(.subheadline)
                            .foregroundStyle(.white)

                        #if os(macOS)
                            HStack { Text("或").foregroundStyle(.white) }
                            Button(
                                action: { audioManager.disk.openFolder() },
                                label: {
                                    Label { Text("打开仓库目录并放入文件") } icon: { Image(systemName: "doc.viewfinder.fill") }
                                }
                            )
                        #endif

                        if Config.isNotDesktop {
                            BtnAdd().buttonStyle(.bordered).foregroundStyle(.white)
                        }
                    }
                case .loading:
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.yellow)
                            Text(Config.isDesktop ? "将音乐文件拖到这里可添加" : "歌曲仓库为空")
                                .font(.title3)
                                .foregroundStyle(.white)
                        }
                        ProgressView()
                            .controlSize(.large)
                            .tint(.white)
                        Text("正在读取仓库")
                            .font(.headline)
                            .foregroundStyle(.white)
                        VStack(spacing: 10) {
                            Text("支持的格式：\(supportedFormats)")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .padding(.top, 6)
                    }
                }
            }
        }.shadow(radius: 8)
    }
}

#Preview {
    AudioDBTips()
        .frame(width: 300, height: 300)
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
