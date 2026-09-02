import Foundation
import SwiftUI

public struct BookDBViewDependencies: Sendable {
    let dbRoot: URL
    let bookDisk: URL?
    let isDesktop: Bool
    let isNotDesktop: Bool

    public init(
        dbRoot: URL,
        bookDisk: URL?,
        isDesktop: Bool,
        isNotDesktop: Bool
    ) {
        self.dbRoot = dbRoot
        self.bookDisk = bookDisk
        self.isDesktop = isDesktop
        self.isNotDesktop = isNotDesktop
    }
}

private struct BookDBViewDependenciesKey: EnvironmentKey {
    static let defaultValue = BookDBViewDependencies(
        dbRoot: FileManager.default.temporaryDirectory,
        bookDisk: nil,
        isDesktop: false,
        isNotDesktop: true
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
