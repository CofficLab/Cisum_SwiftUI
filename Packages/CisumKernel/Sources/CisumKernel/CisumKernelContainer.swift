import Combine
import CisumUI
import Foundation
import SwiftUI

/// Cisum 轻量级内核容器。
///
/// ## 架构原则
///
/// Kernel 只持有各类能力（Provider），不做能力转发。
///
/// 错误示例:
/// ```swift
/// kernel.getAudioList()  // ❌ Kernel 会无限膨胀
/// ```
///
/// 正确示例:
/// ```swift
/// kernel.audio.getAudioList()  // ✅ 能力委托给具体 Provider
/// ```
///
/// 所有具体实现通过 Provider 协议注入，Kernel 不依赖具体实现类。
///
/// ## 使用示例
///
/// ```swift
/// let kernel = CisumKernelContainer()
/// kernel.registerStorage(myStorageService)
/// kernel.registerPlayback(myPlaybackService)
/// try await kernel.startup()
///
/// // 消费服务
/// let location = kernel.storage?.currentLocation
/// kernel.playback?.togglePlayPause()
/// ```
@MainActor
public final class CisumKernelContainer: ObservableObject {
    // MARK: - Service Registry

    /// 服务注册表，以协议类型为键存储已注册的服务实例。
    private var services: [ObjectIdentifier: Any] = [:]

    /// 服务变化订阅（用于转发 ObservableObject 的 objectWillChange）。
    private var serviceSubscriptions: [ObjectIdentifier: AnyCancellable] = [:]

    /// 内置插件管理器。
    public let pluginManager: BuiltinPluginManager

    /// 内核统一事件分发器。
    public let eventManager: EventManager

    // MARK: - Initialization

    public init() {
        self.eventManager = EventManager()
        self.pluginManager = BuiltinPluginManager()
        self.pluginManager.kernel = self
    }

    // MARK: - Generic Service Registry

    /// 注册服务实现。
    ///
    /// 如果服务实现了 `ObservableObject`，内核会自动将其 `objectWillChange`
    /// 转发到自身，使得依赖该服务的 SwiftUI 视图能正确刷新。
    ///
    /// - Parameters:
    ///   - type: 协议类型。
    ///   - instance: 服务实例。
    public func registerService<T>(_ type: T.Type, _ instance: T) {
        let key = ObjectIdentifier(type)
        services[key] = instance
        subscribeToObjectWillChange(observable: instance, key: key)
    }

    /// 解析已注册的服务。
    ///
    /// - Parameter type: 协议类型，默认从返回值类型推导。
    /// - Returns: 已注册的服务实例，未注册时返回 `nil`。
    public func resolveService<T>(_ type: T.Type = T.self) -> T? {
        services[ObjectIdentifier(type)] as? T
    }

    /// 移除已注册的服务。
    ///
    /// - Parameter type: 协议类型。
    public func unregisterService<T>(_ type: T.Type) {
        let key = ObjectIdentifier(type)
        services.removeValue(forKey: key)
        serviceSubscriptions.removeValue(forKey: key)
    }

    // MARK: - Private Helpers

    /// 订阅 ObservableObject 的 objectWillChange，转发到内核自身的 objectWillChange。
    private func subscribeToObjectWillChange<T>(observable: T, key: ObjectIdentifier) {
        guard let observableObject = observable as? any ObservableObject else { return }
        let publisher = observableObject.objectWillChange as! ObservableObjectPublisher
        serviceSubscriptions[key] = publisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.objectWillChange.send()
            }
    }

    // MARK: - Startup

    /// 启动内核，执行自检和初始化流程。
    ///
    /// 启动顺序:
    /// 1. 插件系统 OnBoot — 注册内核服务（alwaysOn 优先，其后可配置）
    /// 2. 服务校验 — 必需服务（Storage / Playback / Plugin / Theme）检查
    /// 3. 插件系统 OnReady — 依赖服务的异步初始化
    /// 4. 贡献聚合 — 失效插件视图缓存，并将主题贡献同步到 CisumUI
    ///
    /// - Throws: `CisumKernelError.missingRequiredServices` 如果必需服务缺失。
    public func startup() async throws {
        // 阶段 1: 插件 OnBoot — 注册核心服务
        try await pluginManager.onBoot(kernel: self)

        // 阶段 2: 服务校验
        let missingServices: [String] = [
            storage == nil ? "Storage" : nil,
            playback == nil ? "Playback" : nil,
            plugin == nil ? "Plugin" : nil,
            theme == nil ? "Theme" : nil,
        ].compactMap { $0 }

        if !missingServices.isEmpty {
            throw CisumKernelError.missingRequiredServices(missingServices)
        }

        // 阶段 3: 插件 OnReady — 异步初始化
        try await pluginManager.onReady(kernel: self)

        // 阶段 4: 贡献聚合 — 失效缓存并将主题同步到 CisumUI
        pluginManager.registerPluginUIContributions(in: self)
    }
}

/// 兼容别名: 使用 `CisumKernel` 替代 `CisumKernelContainer`。
public typealias CisumKernel = CisumKernelContainer
