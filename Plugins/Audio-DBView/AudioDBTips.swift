import MagicKit
import SwiftUI

struct AudioDBTips: View {
    enum Variant {
        case empty
        case loading
        case sorting
    }

    @EnvironmentObject var app: AppProvider
    var variant: Variant = .empty

    var supportedFormats: String {
        AudioPlugin.supportedExtensions.joined(separator: ",")
    }

    var body: some View {
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
                    if let disk = AudioPlugin.getAudioDisk() {
                        HStack { Text("或").foregroundStyle(.white) }

                        Label { Text("打开仓库目录并放入文件") } icon: { Image(systemName: "doc.viewfinder.fill") }
                            .inCard()
                            .hoverScale(105)
                            .inButtonWithAction {
                                disk.openFolder()
                            }
                    }
                #endif

                if Config.isNotDesktop {
                    BtnAdd().buttonStyle(.bordered).foregroundStyle(.white)
                }
            }
            .inCard(color: .autumnOrange)
            .shadow2xl()

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
            .inCard(color: .springGreen)
            .shadow2xl()

        case .sorting:
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
                Text("正在排序")
                    .font(.headline)
                    .foregroundStyle(.white)
                VStack(spacing: 10) {
                    Text("支持的格式：\(supportedFormats)")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.top, 6)
            }
            .inCard(color: .summerBlue)
            .shadow2xl()
        }
    }
}

// MARK: - Preview

#Preview {
    Group {
        AudioDBTips(variant: .empty)
            .frame(width: 300, height: 200)

        AudioDBTips(variant: .loading)
            .frame(width: 300, height: 200)

        AudioDBTips(variant: .sorting)
            .frame(width: 300, height: 200)
    }
    .infinite()
    .inScrollView()
    .frame(height: 800)
    .frame(width: 500)
}

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
