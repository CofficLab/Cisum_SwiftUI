import Foundation
import PluginBook
import SwiftUI

/// 有声书仓库视图依赖：路径与仓库均由 `BookDBPlugin` 自持，
/// 通过 Environment 注入异步解析器（对齐 `BookDBDependencies` 的设置页模式）。
public struct BookDBViewDependencies: @unchecked Sendable {
    let dbRoot: URL
    let bookDisk: URL?
    let isDesktop: Bool
    let isNotDesktop: Bool
    /// 有声书仓库异步解析器：由插件缓存单例，避免每次重复构建 SwiftData 容器。
    let bookRepo: @MainActor @Sendable () async -> BookRepo?

    public init(
        dbRoot: URL,
        bookDisk: URL?,
        isDesktop: Bool,
        isNotDesktop: Bool,
        bookRepo: @escaping @MainActor @Sendable () async -> BookRepo?
    ) {
        self.dbRoot = dbRoot
        self.bookDisk = bookDisk
        self.isDesktop = isDesktop
        self.isNotDesktop = isNotDesktop
        self.bookRepo = bookRepo
    }
}

private struct BookDBViewDependenciesKey: EnvironmentKey {
    static let defaultValue = BookDBViewDependencies(
        dbRoot: FileManager.default.temporaryDirectory,
        bookDisk: nil,
        isDesktop: false,
        isNotDesktop: true,
        bookRepo: { nil }
    )
}

extension EnvironmentValues {
    var bookDBViewDependencies: BookDBViewDependencies {
        get { self[BookDBViewDependenciesKey.self] }
        set { self[BookDBViewDependenciesKey.self] = newValue }
    }

    var bookDBImportAction: @MainActor @Sendable () -> Void {
        get { self[BookDBImportActionKey.self] }
        set { self[BookDBImportActionKey.self] = newValue }
    }
}

private struct BookDBImportActionKey: EnvironmentKey {
    static let defaultValue: @MainActor @Sendable () -> Void = {}
}

public extension View {
    func bookDBViewDependencies(_ dependencies: BookDBViewDependencies) -> some View {
        environment(\.bookDBViewDependencies, dependencies)
    }
}
