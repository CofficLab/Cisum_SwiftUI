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
        ZStack {
            switch variant {
            case .drop:
                VStack(spacing: 20) {
                    HStack {
                        Image.info
                            .foregroundStyle(.blue)
                        Text(Config.isDesktop ? "将音乐文件拖到这里可添加" : "仓库为空")
                            .font(.title3)
                            .foregroundStyle(.black)
                    }
                    Text("支持的格式：\(supportedFormats)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

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

            case .pro:
                VStack(spacing: 20) {
                    HStack {
                        Image.info
                            .foregroundStyle(.blue)
                        Text("基础版本最多支持 \(AudioPlugin.maxAudioCount) 个文件")
                            .font(.title3)
                    }

                    Text("支持的格式：\(supportedFormats)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack {
                        Text("当前订阅：" + StoreService.tierCached().displayName)
                    }
                }
            }
        }
        .inCard(.regularMaterial)
        .shadowMd()
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}

#Preview("AudioCopyTips - Drop Variant") {
    AudioCopyTips(variant: .drop)
        .inRootView()
}

#Preview("AudioCopyTips - Pro Variant") {
    AudioCopyTips(variant: .pro)
        .inRootView()
}
