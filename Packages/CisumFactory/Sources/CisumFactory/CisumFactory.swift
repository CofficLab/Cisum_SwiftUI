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

        // 当前阶段 Factory 只负责把 Kernel 准备好，插件尚未注入。
        // CisumKernel 的服务自检依赖插件注册 Storage/Playback/Plugin/Theme，
        // 因此空清单时不能执行 startup，否则应用会在布局显示前失败。
        // 插件清单接入后恢复完整的两阶段启动流程。
        if plugins.isEmpty {
            kernels.append(kernel)
            print("\(Self.t)Kernel prepared with no plugins; waiting for plugin injection")
            return kernel
        }

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
        WindowMain()
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

/// Factory 的主窗口启动视图。
///
/// 负责创建 Kernel，并在 Kernel 准备完成后显示 Factory 内部的 AppLayoutView。
public struct WindowMain: View {
    @State private var kernel: CisumKernel?
    @State private var initializationError: Error?
    @State private var isInitializing = true

    public init() {}

    public var body: some View {
        Group {
            if isInitializing {
                KernelLoadingView()
            } else if let initializationError {
                KernelErrorView(error: initializationError)
            } else if let kernel {
                AppLayoutView(kernel: kernel)
            }
        }
        .task {
            await initializeKernel()
        }
    }

    private func initializeKernel() async {
        guard kernel == nil, initializationError == nil else { return }

        do {
            kernel = try await CisumFactory.createMainKernel()
        } catch {
            initializationError = error
        }
        isInitializing = false
    }
}

private struct KernelLoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading…")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct KernelErrorView: View {
    let error: Error

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text("Unable to start Cisum")
                .font(.title2)
            Text(error.localizedDescription)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 520)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 兼容别名。
public typealias CisumFactory = CisumBuilder
