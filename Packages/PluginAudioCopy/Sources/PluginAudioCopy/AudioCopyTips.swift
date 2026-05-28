import CisumUI
import MagicKit
import PluginAudio
import PluginStore
import SwiftUI

struct AudioCopyTips: View {
    enum Variant {
        case drop
        case pro
    }

    var variant: Variant = .drop

    var supportedFormats: [String] {
        AudioPluginInfo.supportedExtensions
    }

    var body: some View {
        ZStack {
            switch variant {
            case .drop:
                VStack(spacing: 24) {
                    Image(systemName: "arrow.down.doc")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue.opacity(0.6))

                    Text("拖放音乐文件到这里", tableName: "Audio-Copy-macOS", bundle: .module)
                        .font(.title3)
                        .foregroundStyle(.primary)

                    // 格式展示
                    formatChipsView
                }
                .padding()
                .frame(maxWidth: .infinity)
                .cisumInfinite()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(.blue, style: .init(lineWidth: 2, dash: [8, 6]))
                        )
                        .padding()
                )

            case .pro:
                VStack(spacing: 20) {
                    HStack {
                        Image.cisumInfo
                            .foregroundStyle(.blue)
                        Text("基础版本最多支持 \(AudioPluginInfo.maxAudioCount) 个文件", tableName: "Audio-Copy-macOS", bundle: .module)
                            .font(.title3)
                    }

                    // 优化后的格式展示
                    formatChipsView

                    HStack {
                        Text("当前订阅：", tableName: "Audio-Copy-macOS", bundle: .module) + Text(StoreService.tierCached().displayName)
                    }
                }
            }
        }
        .background(.regularMaterial)
        .cisumShadowMd()
    }

    /// 格式标签视图
    private var formatChipsView: some View {
        VStack(spacing: 8) {
            Text("支持的格式", tableName: "Audio-Copy-macOS", bundle: .module)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)

            HStack(spacing: 8) {
                ForEach(supportedFormats, id: \.self) { format in
                    HStack(spacing: 4) {
                        Image.cisumMusicNote
                            .font(.caption2)
                        Text(format.uppercased())
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}
