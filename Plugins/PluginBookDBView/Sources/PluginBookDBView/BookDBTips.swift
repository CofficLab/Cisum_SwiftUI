import CisumUI
import PluginBook
import SwiftUI

/**
 * 用途：展示书籍仓库的状态提示信息
 * 属性说明：
 *   - variant: 提示类型（empty: 空状态, loading: 加载中）
 * 使用场景：在书籍列表为空或正在加载时显示友好的提示界面
 */
struct BookDBTips: View {
    enum Variant {
        case empty
        case loading
    }

    @Environment(\.bookDBViewDependencies) private var dependencies
    @Environment(\.bookDBImportAction) private var requestImport
    @LumiTheme private var appTheme
    var variant: Variant = .empty

    var supportedFormats: String {
        BookPluginInfo.supportedExtensions.joined(separator: ",")
    }

    var body: some View {
        VStack(spacing: 20) {
            switch variant {
            case .empty:
                AppEmptyState(
                    icon: "book.closed",
                    title: dependencies.isDesktop ? "将有声书文件夹拖到这里可添加" : "仓库为空",
                    description: String(localized: "支持的格式：\(supportedFormats)", table: "Book-DBView", bundle: .module)
                )
                .frame(minHeight: 160)

                #if os(macOS)
                    Text("或", tableName: "Book-DBView", bundle: .module)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button(
                        action: {
                            if let disk = dependencies.bookDisk {
                                disk.openFolder()
                            }
                        },
                        label: {
                            Label { Text("打开仓库目录并放入文件", tableName: "Book-DBView", bundle: .module) } icon: { Image(systemName: "doc.viewfinder.fill") }
                        }
                    )
                #endif

                if dependencies.isNotDesktop {
                    Button(
                        action: requestImport,
                        label: {
                            Label(
                                title: { Text("添加", tableName: "Book-DBView", bundle: .module) },
                                icon: { Image(systemName: "plus.circle") }
                            )
                        }
                    )
                    .buttonStyle(.bordered)
                }
            case .loading:
                AppLoadingOverlay(message: "正在读取仓库", size: .large)
                    .frame(height: 120)
                Text("支持的格式：\(supportedFormats)", tableName: "Book-DBView", bundle: .module)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(appTheme.surface.opacity(0.85))
        .cisumRoundedMedium()
        .shadow(radius: 8)
    }
}

// MARK: - Preview



#if os(macOS)

#endif
