import CisumUI
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

    @EnvironmentObject var app: AppProvider
    @LumiTheme private var appTheme
    var variant: Variant = .empty

    var supportedFormats: String {
        BookPlugin.supportedExtensions.joined(separator: ",")
    }

    var body: some View {
        VStack(spacing: 20) {
            switch variant {
            case .empty:
                AppEmptyState(
                    icon: "book.closed",
                    title: Config.isDesktop ? "将有声书文件夹拖到这里可添加" : "仓库为空",
                    description: String(localized: "支持的格式：\(supportedFormats)", table: "Book-DBView")
                )
                .frame(minHeight: 160)

                #if os(macOS)
                    Text("或", tableName: "Book-DBView")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button(
                        action: {
                            if let disk = BookPlugin.getBookDisk() {
                                disk.openFolder()
                            }
                        },
                        label: {
                            Label { Text("打开仓库目录并放入文件", tableName: "Book-DBView") } icon: { Image(systemName: "doc.viewfinder.fill") }
                        }
                    )
                #endif

                if Config.isNotDesktop {
                    BtnAdd().buttonStyle(.bordered)
                }
            case .loading:
                AppLoadingOverlay(message: "正在读取仓库", size: .large)
                    .frame(height: 120)
                Text("支持的格式：\(supportedFormats)", tableName: "Book-DBView")
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

#Preview("空状态") {
    BookDBTips(variant: .empty)
        .frame(width: 300, height: 300)
}

#Preview("加载中") {
    BookDBTips(variant: .loading)
        .frame(width: 300, height: 300)
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
