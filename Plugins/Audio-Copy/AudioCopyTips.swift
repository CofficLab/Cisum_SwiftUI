import MagicKit
import MagicUI
import SwiftUI

struct AudioCopyTips: View {
    enum Variant {
        case drop
        case pro
    }

    @EnvironmentObject var app: AppProvider
    var variant: Variant = .drop

    var supportedFormats: String {
        AudioPlugin.supportedExtensions.joined(separator: ",")
    }

    var body: some View {
        switch variant {
        case .drop:
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.yellow)
                    Text(Config.isDesktop ? "将音乐文件拖到这里可添加" : "仓库为空")
                        .font(.title3)
                        .foregroundStyle(.black)
                }
                Text("支持的格式：\(supportedFormats)")
                    .font(.subheadline)
                    .foregroundStyle(.black)

                #if os(macOS)
                    if let disk = AudioPlugin.getAudioDisk() {
                        HStack { Text("或").foregroundStyle(.black) }
                        Button(
                            action: { disk.openFolder() },
                            label: {
                                Label { Text("打开仓库目录并放入文件") } icon: { Image(systemName: "doc.viewfinder.fill") }
                            }
                        )
                    }
                #endif

                if Config.isNotDesktop {
                    BtnAdd().buttonStyle(.bordered).foregroundStyle(.white)
                }
            }
            .inCard(color: .winterBlue)
            .shadow3xl()

        case .pro:
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    Text("基础版本最多支持 \(AudioPlugin.maxAudioCount) 个文件")
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                Text("支持的格式：\(supportedFormats)")
                    .font(.subheadline)
                    .foregroundStyle(.white)

                HStack {
                    Text("当前订阅：" + StoreService.tierCached().displayName)
                        .foregroundStyle(.white)
                }
            }
            .inCard(color: .orangeFruit)
            .shadow3xl()
        }
    }
}

// MARK: - Preview

#Preview {
    Group {
        AudioCopyTips(variant: .drop)
            .frame(width: 300, height: 200)

        AudioCopyTips(variant: .pro)
            .frame(width: 300, height: 150)
    }
    .inScrollView()
    .frame(height: 600)
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
            .frame(width: 600, height: 600)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
