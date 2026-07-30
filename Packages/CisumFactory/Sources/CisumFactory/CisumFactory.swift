import CisumKernel
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// Cisum 应用组装工厂（Composition Root）。
///
/// 唯一知道"如何组装应用"的地方：
/// - 内核生命周期管理（创建、启动、销毁）
/// - 插件清单维护（通过 `PluginService`）
/// - 窗口 / 命令工厂方法
///
/// ## 核心流程
///
/// ```swift
/// // 1. App 入口调用
/// let kernel = try await CisumFactory.createMainKernel()
///
/// // 2. 内部流程
/// CisumKernel()                            // 创建内核容器
///   -> PluginService.plugins               // 获取插件清单
///   -> kernel.pluginManager.initializePlugins(...) // 初始化插件
///   -> kernel.startup()                    // 两阶段启动
///       -> pluginManager.onBoot(kernel:)   // 阶段 1: 注册服务
///       -> 服务校验                         // 必需服务检查
///       -> pluginManager.onReady(kernel:)  // 阶段 2: 异步初始化
///
/// // 3. 窗口工厂
/// CisumFactory.makeMainWindow()            // 主窗口
/// CisumFactory.makeSettingsWindow()        // 设置窗口
/// CisumFactory.makeCommands()              // 命令菜单
/// ```
@MainActor
public enum CisumBuilder: SuperLog {
    nonisolated static let logger = Logger(subsystem: "com.coffic.cisum", category: "factory")
    nonisolated public static let emoji = "🏭"
    nonisolated static let verbose = true

    // MARK: - Kernel Registry

    /// 已创建的内核列表（支持多内核）。
    public private(set) static var kernels: [CisumKernel] = []

    /// 主内核，取内核列表中的首个。
    public static var mainKernel: CisumKernel? { kernels.first }

    // MARK: - Kernel Factory

    /// 创建并启动一个新内核。
    ///
    /// 流程：
    /// 1. 创建 `CisumKernel` 实例
    /// 2. 从 `PluginService` 获取插件清单
    /// 3. 初始化插件到 `BuiltinPluginManager`
    /// 4. 订阅插件启用/禁用变更
    /// 5. 启动内核（两阶段生命周期 + 服务校验）
    /// 6. 注册到内核列表
    ///
    /// - Returns: 已启动的 `CisumKernel` 实例。
    /// - Throws: 内核启动失败（如必需服务缺失）。
    public static func createKernel() async throws -> CisumKernel {
        let kernel = CisumKernel()

        // 获取插件清单
        let plugins = PluginService.plugins

        // 初始化插件（转换为 existential 类型）
        kernel.pluginManager.initializePlugins(plugins.map { $0 })

        // 订阅插件变更
        subscribeToPluginChanges(kernel: kernel)

        // 启动内核
        try await kernel.startup()

        // 注册到内核列表
        kernels.append(kernel)

        print("\(Self.t)Kernel created and started successfully")
        return kernel
    }

    /// 创建主内核（幂等）。
    ///
    /// 如果主内核已存在则直接返回，否则创建新的。
    ///
    /// - Returns: 已启动的主 `CisumKernel` 实例。
    /// - Throws: 内核启动失败。
    public static func createMainKernel() async throws -> CisumKernel {
        if let existing = mainKernel {
            print("\(Self.t)Main kernel already exists, returning existing instance")
            return existing
        }
        return try await createKernel()
    }

    /// 销毁指定内核。
    ///
    /// - Parameter kernel: 要销毁的内核实例。
    public static func destroyKernel(_ kernel: CisumKernel) {
        kernels.removeAll { $0 === kernel }
        print("\(Self.t)Kernel destroyed, remaining: \(kernels.count)")
    }

    /// 销毁所有内核。
    public static func destroyAllKernels() {
        kernels.removeAll()
        print("\(Self.t)All kernels destroyed")
    }

    // MARK: - Window Factory

    /// 创建主窗口视图。
    ///
    /// 内部调用 `CisumFactory.createMainKernel()` 初始化内核，
    /// 显示加载中 / 崩溃 / 正常三种状态。
    public static func makeMainWindow() -> some View {
        // TODO: 返回主窗口视图
        EmptyView()
    }

    /// 创建设置窗口视图。
    public static func makeSettingsWindow() -> some View {
        // TODO: 返回设置窗口视图
        EmptyView()
    }

    // MARK: - Commands Factory

    /// 创建应用命令菜单。
    public static func makeCommands() -> some Commands {
        // TODO: 返回应用命令
        EmptyCommands()
    }

    // MARK: - Private

    /// 订阅插件启用/禁用变更通知。
    ///
    /// 插件在运行时切换启用状态后，通知工厂重建插件贡献并刷新 UI。
    /// 当前阶段插件清单为空，此处预留事件监听供后续扩展。
    private static func subscribeToPluginChanges(kernel: CisumKernel) {
        NotificationCenter.default.addObserver(
            forName: .cisumEnabledPluginsDidChange,
            object: nil,
            queue: .main
        ) { _ in
            // TODO: 后续在 BuiltinPluginManager 中添加 rebuildAllContributions 后接入
            print("\(Self.t)Plugin enabled state changed, rebuild pending")
        }
    }
}

/// 兼容别名。
public typealias CisumFactory = CisumBuilder
