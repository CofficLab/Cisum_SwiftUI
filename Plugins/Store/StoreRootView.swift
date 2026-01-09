import OSLog
import SwiftUI
import MagicKit

/// Store 插件的 RootView
/// 用于执行 Store 相关的初始化操作
struct StoreRootView<Content: View>: View, SuperLog {
    nonisolated static var emoji: String {"🏪"}
    
    private let content: Content
    @State private var isInitialized = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .task {
                await initializeStore()
            }
            .onDisappear {
                cleanupStore()
            }
    }
}

// MARK: - Action

extension StoreRootView {
    /// 初始化 Store 相关服务
    private func initializeStore() async {
        guard !isInitialized else { return }

        os_log("\(self.t)🚀 初始化 Store 服务")

        // 这里可以执行 Store 插件特有的初始化操作
        // 例如：预加载产品数据、设置监听器等
        do {
            let _ = try await StoreService.fetchAllProducts()
            os_log("\(self.t)✅ 产品数据预加载完成")
        } catch let error {
            os_log(.error, "\(self.t)❌ 预加载产品数据出错 -> \(error.localizedDescription)")
        }

        isInitialized = true
        os_log("\(self.t)✅ 服务初始化完成")
    }

    /// 清理 Store 相关资源
    private func cleanupStore() {
        os_log("\(self.t)📴 清理 Store 资源")

        // 这里可以执行 Store 插件特有的清理操作
        // 例如：取消网络请求、清理缓存等

        isInitialized = false
    }
}

// MARK: - Preview

#Preview("Buy") {
    PurchaseView()
        .inRootView()
        .frame(height: 800)
}

#Preview("APP") {
    ContentView()
        .inRootView()
        .frame(width: 700)
        .frame(height: 800)
}
