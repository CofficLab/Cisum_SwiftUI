import ProviderBook
import ProviderBook
import SwiftUI

/// 有声书仓库设置页依赖：仓库路径 / 仓库均由 `BookDBPlugin` 自持
/// （直接从内核存储服务解析，不依赖 `BookPlugin` 静态入口）。
public struct BookDBDependencies: @unchecked Sendable {
    public var bookRepo: @MainActor @Sendable () async -> BookRepo?
    public var bookDisk: @MainActor @Sendable () -> URL?

    public init(
        bookRepo: @escaping @MainActor @Sendable () async -> BookRepo?,
        bookDisk: @escaping @MainActor @Sendable () -> URL?
    ) {
        self.bookRepo = bookRepo
        self.bookDisk = bookDisk
    }

    public static let empty = BookDBDependencies(
        bookRepo: { nil },
        bookDisk: { nil }
    )
}

private struct BookDBDependenciesKey: EnvironmentKey {
    static let defaultValue = BookDBDependencies.empty
}

public extension EnvironmentValues {
    var bookDBDependencies: BookDBDependencies {
        get { self[BookDBDependenciesKey.self] }
        set { self[BookDBDependenciesKey.self] = newValue }
    }
}
