import Foundation
import MagicKit
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

public final class BookRepoState: ObservableObject {
    @Published var repo: BookRepo? = nil
    @Published var container: ModelContainer? = nil
    @Published var error: Error? = nil
    @Published var isLoading: Bool = true
}

public struct BookRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { "🏓" }
    public nonisolated static var verbose: Bool { false }

    private var content: Content
    private let dbRootURL: @MainActor () throws -> URL
    private let bookDisk: @MainActor () -> URL?
    private let storageLocationDidChangeNotifications: [Notification.Name]
    @StateObject private var bookRepoState = BookRepoState()

    public init(
        dbRootURL: @escaping @MainActor () throws -> URL,
        bookDisk: @escaping @MainActor () -> URL?,
        storageLocationDidChangeNotifications: [Notification.Name] = [],
        @ViewBuilder content: () -> Content
    ) {
        self.dbRootURL = dbRootURL
        self.bookDisk = bookDisk
        self.storageLocationDidChangeNotifications = storageLocationDidChangeNotifications
        self.content = content()
    }

    public var body: some View {
        Group {
            if let error = bookRepoState.error {
                error.makeView()
            } else if bookRepoState.isLoading {
                ProgressView {
                    Text("正在初始化...", tableName: "Book", bundle: .module)
                }
            } else if let container = bookRepoState.container, let repo = bookRepoState.repo {
                ZStack {
                    content
                }
                .modelContainer(container)
                .environmentObject(repo)
            } else {
                Text("初始化失败", tableName: "Book", bundle: .module)
            }
        }
        .modifier(BookStorageChangeModifier(notificationNames: storageLocationDidChangeNotifications) {
            self.initAll()
        })
        .onAppear {
            self.initAll()
        }
    }
}

// MARK: - Action

extension BookRootView {
    private func initAll() {
        if Self.verbose {
            os_log("\(self.t)InitAll")
        }
        bookRepoState.isLoading = true
        bookRepoState.error = nil

        Task {
            do {
                // 1. 初始化 Container
                let dbRootURL = try await MainActor.run {
                    try self.dbRootURL()
                }
                let container = try BookConfig.getContainer(dbRootURL: dbRootURL)
                if Self.verbose {
                    os_log("\(self.t)🎉 Container 初始化成功")
                }

                // 2. 获取 Disk
                let disk = await MainActor.run {
                    self.bookDisk()
                }
                guard let disk else {
                    await MainActor.run {
                        self.setBookRepoState(nil, container: nil, error: BookPluginError.initialization(reason: "Disk 未找到"))
                    }
                    return
                }
                if Self.verbose {
                    os_log("\(self.t)🎉 Disk 获取成功: \(disk.shortPath())")
                }

                // 3. 初始化 BookRepo
                let db = BookDB(container, reason: self.className)
                let repo = try BookRepo(disk: disk, db: db)

                await MainActor.run {
                    self.setBookRepoState(repo, container: container)
                    if Self.verbose {
                        os_log("\(self.t)🎉 BookRepo 初始化成功")
                    }
                }
            } catch {
                await MainActor.run {
                    self.setBookRepoState(nil, container: nil, error: error)
                    os_log("❌初始化失败: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Setter

extension BookRootView {
    @MainActor private func setBookRepoState(_ repo: BookRepo?, container: ModelContainer?, error: Error? = nil) {
        bookRepoState.repo = repo
        bookRepoState.container = container
        bookRepoState.error = error
        bookRepoState.isLoading = false
    }
}

// MARK: - Event Handler

private struct BookStorageChangeModifier: ViewModifier {
    let notificationNames: [Notification.Name]
    let action: () -> Void

    func body(content: Content) -> some View {
        notificationNames.reduce(AnyView(content)) { view, name in
            AnyView(view.onReceive(NotificationCenter.default.publisher(for: name)) { _ in
                action()
            })
        }
    }
}
