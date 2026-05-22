import CisumUI
import SwiftUI

struct AudioDBTips: View {
    enum Variant {
        case empty
        case loading
        case sorting
    }

    @EnvironmentObject var app: AppProvider
    @LumiTheme private var appTheme
    var variant: Variant = .empty

    var supportedFormats: String {
        AudioPlugin.supportedExtensions.joined(separator: ",")
    }

    var body: some View {
        VStack(spacing: 20) {
            switch variant {
            case .empty:
                AppEmptyState(
                    icon: "music.note.list",
                    title: Config.isDesktop ? "将音乐文件拖到这里可添加" : "歌曲仓库为空",
                    description: String(localized: "支持的格式：\(supportedFormats)", table: "Audio-DBView")
                )
                .frame(minHeight: 160)

                #if os(macOS)
                    if let disk = AudioPlugin.getAudioDisk() {
                        Text("或", tableName: "Audio-DBView")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Label { Text("打开仓库目录并放入文件", tableName: "Audio-DBView") } icon: { Image(systemName: "doc.viewfinder.fill") }
                            .cisumCard(.regularMaterial)
                            .cisumShadowSm()
                            .cisumHoverScale(105)
                            .cisumButton {
                                disk.openFolder()
                            }
                    }
                #endif

                BtnAdd().buttonStyle(.bordered).cisumIf(Config.isNotDesktop)

            case .loading:
                AppLoadingOverlay(message: "正在读取仓库", size: .large)
                    .frame(height: 120)
                Text("支持的格式：\(supportedFormats)", tableName: "Audio-DBView")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

            case .sorting:
                AppLoadingOverlay(message: "正在排序", size: .large)
                    .frame(height: 120)
                Text("支持的格式：\(supportedFormats)", tableName: "Audio-DBView")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(appTheme.surface.opacity(0.85))
        .background(appTheme.background.opacity(0.5))
        .cisumRoundedMedium()
        .cisumShadowXl()
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
    .cisumInfinite()
    .cisumScrollView()
    .frame(height: 800)
    .frame(width: 500)
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
