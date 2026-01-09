import Foundation
import MagicKit
import OSLog
import StoreKit
import SwiftData
import SwiftUI

/// 插件提供者
///
/// 负责管理应用中的所有插件，包括插件的注册、发现、激活和生命周期管理。
/// 提供插件视图的包裹、工具栏按钮、状态视图和弹窗视图的统一管理。
///
/// ## 主要功能
/// - 自动发现和注册插件
/// - 管理当前激活的分组插件
/// - 提供插件视图的链式包裹功能
/// - 统一管理插件提供的各类视图组件
///
/// ## 注意事项
/// - 该类必须在主线程上使用（`@MainActor`）
/// - 插件按注册顺序进行视图包裹
@MainActor
class PluginProvider: ObservableObject, SuperLog, SuperThread {
    nonisolated static let emoji = "🧩"
    static let verbose = false
    
    /// 插件仓库，用于持久化插件配置
    private let repo: PluginRepo

    /// 所有已注册的插件列表
    @Published private(set) var plugins: [SuperPlugin] = []
    
    /// 当前激活的分组插件
    @Published private(set) var current: SuperPlugin?

    /// 获取所有分组类型的插件
    var groupPlugins: [SuperPlugin] {
        plugins.filter { $0.isGroup }
    }

    /// 初始化插件提供者
    ///
    /// 使用预定义的插件列表初始化，并尝试恢复上次激活的插件。
    ///
    /// - Parameters:
    ///   - plugins: 预定义的插件列表
    ///   - repo: 插件仓库，用于持久化插件配置
    init(plugins: [SuperPlugin], repo: PluginRepo) {
        

        self.plugins = plugins
        self.repo = repo
        let currentPluginId = repo.getCurrentPluginId()

        if let plugin = plugins.first(where: { $0.id == currentPluginId }) {
            try? self.setCurrentGroup(plugin)
        }
    }
    
    /// 初始化插件提供者（支持自动发现）
    ///
    /// 如果启用自动发现，将通过 `PluginRegistry` 自动注册和构建所有插件。
    /// 这是推荐的初始化方式，可以自动发现项目中的所有插件。
    ///
    /// - Parameters:
    ///   - autoDiscover: 是否自动发现和注册插件，默认为 `true`
    ///   - repo: 插件仓库，用于持久化插件配置
    init(autoDiscover: Bool = true, repo: PluginRepo) {
        if Self.verbose {
            
        }
        
        self.repo = repo
        
        if autoDiscover {
            autoRegisterPlugins()
            Task { [weak self] in
                guard let self else { return }
                let discoveredPlugins = await PluginRegistry.shared.buildAll()
                await MainActor.run {
                    self.plugins = discoveredPlugins
                    let currentPluginId = self.repo.getCurrentPluginId()
                    
                    if let plugin = discoveredPlugins.first(where: { $0.id == currentPluginId }) {
                        try? self.setCurrentGroup(plugin)
                    } else if let first = discoveredPlugins.first(where: { $0.isGroup }) {
                        try? self.setCurrentGroup(first)
                    }
                }
            }
        } else {
            self.plugins = []
        }
    }

    /// 获取所有插件提供的状态视图
    ///
    /// 遍历所有已注册的插件，收集它们提供的状态视图（如果有）。
    /// 状态视图通常显示在应用的状态栏或顶部区域。
    ///
    /// - Returns: 包含所有插件状态视图的数组
    func getStatusViews() -> [AnyView] {
        let items = plugins.compactMap { $0.addStatusView() }

        // os_log("\(self.t)GetRootViews: \(items.count)")

        return items
    }

    /// 将内容依序用所有插件的 RootView 包裹（链式装配）
    ///
    /// 按照插件注册顺序，依次用每个插件的 `addRootView` 方法包裹内容视图。
    /// 这实现了类似中间件的功能，每个插件可以在视图层级中添加自己的包装层。
    ///
    /// ## 工作原理
    /// 1. 从原始内容开始
    /// 2. 按 `plugins` 数组顺序遍历
    /// 3. 每个插件可以选择包裹当前视图或直接返回
    /// 4. 最终返回完全包裹后的视图
    ///
    /// ## 示例
    /// ```swift
    /// // 假设有三个插件 A, B, C
    /// // 最终视图层级：A(B(C(原始内容)))
    /// ```
    ///
    /// - Parameter content: 需要被包裹的原始视图内容
    /// - Returns: 经过所有插件包裹后的视图，如果没有插件则返回原始内容
    func wrapWithCurrentRoot<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        var wrapped: AnyView = AnyView(content())

        for plugin in plugins {
            wrapped = plugin.wrapRoot(wrapped)
        }

        return wrapped
    }

    /// 获取所有插件提供的弹窗视图
    ///
    /// 遍历所有已注册的插件，收集它们提供的弹窗视图（如设置面板、信息窗口等）。
    ///
    /// - Parameter storage: 当前的存储位置，某些插件可能需要根据存储位置提供不同的弹窗视图
    /// - Returns: 包含所有插件弹窗视图的数组
    func getSheetViews(storage: StorageLocation?) -> [AnyView] {
        let items = plugins.compactMap { $0.addSheetView(storage: storage) }

        // os_log("\(self.t)GetRootViews: \(items.count)")

        return items
    }

    /// 获取所有插件提供的工具栏按钮
    ///
    /// 遍历所有已注册的插件，收集它们提供的工具栏按钮。
    /// 每个按钮包含唯一的 ID 和对应的视图。
    ///
    /// - Returns: 包含按钮 ID 和视图的元组数组
    func getToolBarButtons() -> [(id: String, view: AnyView)] {
        let buttons =  plugins.flatMap { $0.addToolBarButtons() }
        
        if Self.verbose {
            os_log("\(self.t)🏃🏃🏃 getToolBarButtons: \(buttons.count)")
        }
        
        return buttons
    }

    /// 设置当前激活的分组插件
    ///
    /// 将指定的插件设置为当前激活的分组插件，并持久化该选择。
    /// 只有标记为分组类型（`isGroup = true`）的插件才能被设置为当前插件。
    ///
    /// - Parameters:
    ///   - plugin: 要激活的插件，必须是分组类型
    ///   - verbose: 是否输出详细日志，默认为 `false`
    /// - Throws: `PluginProviderError.pluginIsNotGroup` 如果插件不是分组类型
    func setCurrentGroup(_ plugin: SuperPlugin, verbose: Bool = false) throws {
        let oldPluginId = self.current?.id ?? "nil"
        let newPluginId = plugin.id
        
        if verbose || Self.verbose {
            os_log("\(self.t)🏃 SetCurrentGroup: \(oldPluginId) -> \(newPluginId)")
        }

        if plugin.isGroup {
            self.current = plugin
            repo.storeCurrentPluginId(plugin.id)
            
            if verbose || Self.verbose {
                os_log("\(self.t)✅ 插件切换成功，将触发依赖视图更新")
            }
        } else {
            os_log(.error, "\(self.t)❌ 插件切换失败: \(plugin.id) 不是分组类型")
            throw PluginProviderError.pluginIsNotGroup(pluginId: plugin.id)
        }
    }

    /// 根据插件 ID 切换当前分组插件
    ///
    /// - Parameter id: 分组插件的唯一标识
    func setCurrentGroup(id: String, verbose: Bool = false) throws {
        guard let target = plugins.first(where: { $0.id == id }) else {
            os_log(.error, "\(self.t)❌ 插件切换失败: 未找到 id=\(id)")
            throw PluginProviderError.pluginNotFound(pluginId: id)
        }
        try setCurrentGroup(target, verbose: verbose)
    }

    /// 重置插件提供者
    ///
    /// 清空所有插件列表和当前激活的插件。
    /// 通常用于应用重置或重新初始化场景。
    func reset() {
        self.plugins = []
        self.current = nil
    }

    /// 恢复上次激活的插件
    ///
    /// 从持久化存储中读取上次激活的插件 ID，并尝试恢复该插件为当前插件。
    /// 如果找不到上次的插件，则激活第一个可用的分组插件。
    ///
    /// ## 恢复逻辑
    /// 1. 尝试恢复存储的插件 ID
    /// 2. 如果找不到，使用第一个分组插件
    /// 3. 如果都没有，记录错误日志
    ///
    /// - Throws: `PluginProviderError` 如果插件不是分组类型
    func restoreCurrent() throws {
        let currentPluginId = repo.getCurrentPluginId()

        if let plugin = plugins.first(where: { $0.id == currentPluginId }) {
            try self.setCurrentGroup(plugin)
        } else if let first = plugins.first(where: { $0.isGroup }) {
            try self.setCurrentGroup(first)
        } else {
            os_log(.error, "\(self.t)⚠️⚠️⚠️ No current plugin found")
        }
    }
}

// MARK: - Event Handler

extension PluginProvider {
    /// 对所有插件执行异步操作
    ///
    /// 遍历所有已注册的插件，对每个插件执行指定的异步操作。
    /// 如果某个插件的操作失败，会捕获错误并记录日志，然后继续处理下一个插件。
    ///
    /// - Parameter operation: 要对每个插件执行的异步操作闭包
    func executePluginOperation(_ operation: @Sendable (SuperPlugin) async throws -> Void) async {
        for plugin in plugins {
            do {
                try await operation(plugin)
            } catch {
                os_log(.error, "\(self.t)Plugin operation failed: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Error

/// 插件提供者错误类型
///
/// 定义了插件管理过程中可能出现的错误情况。
enum PluginProviderError: Error, LocalizedError {
    /// 插件未找到
    ///
    /// 当根据 ID 查找插件失败时抛出此错误。
    ///
    /// - Parameter pluginId: 插件的唯一标识符
    case pluginNotFound(pluginId: String)
    
    /// 插件不是分组类型
    ///
    /// 当尝试将非分组插件设置为当前插件时抛出此错误。
    ///
    /// - Parameter pluginId: 插件的唯一标识符
    case pluginIsNotGroup(pluginId: String)
    
    /// 插件 ID 重复
    ///
    /// 当尝试注册具有重复 ID 的插件时抛出此错误。
    ///
    /// - Parameters:
    ///   - pluginId: 重复的插件 ID
    ///   - collection: 已存在的插件 ID 集合
    case duplicatePluginID(pluginId: String, collection: [String])
    
    /// 插件 ID 为空
    ///
    /// 当插件的 ID 为空字符串时抛出此错误。
    case pluginIDIsEmpty

    var errorDescription: String? {
        switch self {
        case let .pluginNotFound(pluginId):
            return "Plugin \(pluginId) not found"
        case let .pluginIsNotGroup(pluginId):
            return "Plugin \(pluginId) is not a group"
        case let .duplicatePluginID(pluginId, collection):
            return "Plugin with ID \(pluginId) already exists in collection: \(collection)"
        case .pluginIDIsEmpty:
            return "Plugin has an empty ID"
        }
    }
}

#if os(macOS)
#Preview("Small Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 500)
    .frame(height: 600)
}

#Preview("Big Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 800)
    .frame(height: 1200)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
