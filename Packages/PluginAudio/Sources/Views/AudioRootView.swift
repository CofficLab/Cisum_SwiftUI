import Foundation
import CisumUIComponents
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct AudioRootErrorPresentation: Equatable {
    let title: String
    let message: String
    let detail: String?

    static func make(error: AudioPluginError?) -> AudioRootErrorPresentation {
        guard let error else {
            return AudioRootErrorPresentation(
                title: String(localized: "Audio Library Initialization Failed", bundle: .module),
                message: String(localized: "Try reopening the app or checking media library settings.", bundle: .module),
                detail: nil
            )
        }

        switch error {
        case .initialization(let reason) where reason == AudioRootErrorPresentation.storageMissingReason:
            return AudioRootErrorPresentation(
                title: String(localized: "Storage Location Not Set", bundle: .module),
                message: String(localized: "Set the media library storage location first.", bundle: .module),
                detail: nil
            )
        default:
            return AudioRootErrorPresentation(
                title: String(localized: "Audio Library Initialization Failed", bundle: .module),
                message: error.recoverySuggestion ?? String(localized: "Try reopening the app or checking media library settings.", bundle: .module),
                detail: error.localizedDescription
            )
        }
    }

    static let storageMissingReason = "Storage not found"
}

private enum AudioContainerLoadError: Error {
    case message(String)
}

public struct AudioRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { "📢" }
    public nonisolated static var verbose: Bool { false }

    @State private var error: AudioPluginError? = nil
    @State private var container: ModelContainer? = nil
    @State private var isInitializing = true
    @State private var initGeneration = 0
    private var content: Content
    private let databaseURL: @MainActor () throws -> URL
    private let hasStorageLocation: @MainActor () -> Bool
    private let storageLocationDidChangeNotifications: [Notification.Name]

    var repo: AudioRepo?

    public init(
        databaseURL: @escaping @MainActor () throws -> URL,
        hasStorageLocation: @escaping @MainActor () -> Bool,
        storageLocationDidChangeNotifications: [Notification.Name] = [],
        @ViewBuilder content: () -> Content
    ) {
        if Self.verbose {
            os_log("\(Self.t)初始化开始")
        }

        self.databaseURL = databaseURL
        self.hasStorageLocation = hasStorageLocation
        self.storageLocationDidChangeNotifications = storageLocationDidChangeNotifications
        self.content = content()
        self._container = State(initialValue: nil)
        self._error = State(initialValue: nil)
        self._isInitializing = State(initialValue: true)
        self._initGeneration = State(initialValue: 0)

        if Self.verbose {
            os_log("\(Self.t)初始化完成")
        }
    }

    public var body: some View {
        Group {
            if isInitializing {
                ProgressView {
                    Text("Initializing...", bundle: .module)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if error != nil {
                storageErrorView
            } else if let container = self.container {
                ZStack {
                    content
                }
                .modelContainer(container)
                .onDisappear(perform: handleOnDisappear)
            } else {
                storageErrorView
            }
        }
        .modifier(AudioStorageChangeModifier(notificationNames: storageLocationDidChangeNotifications) {
            reloadContainer()
            handleStorageLocationChanged()
        })
        .task {
            reloadContainer()
        }
    }

    // MARK: - Error View

    private var storageErrorView: some View {
        let presentation = AudioRootErrorPresentation.make(error: error)

        return VStack(spacing: 20) {
            Spacer()

            Image(systemName: "externaldrive.badge.exclamationmark")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: 8) {
                Text(presentation.title)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Text(presentation.message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if let detail = presentation.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .textSelection(.enabled)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

private struct AudioStorageChangeModifier: ViewModifier {
    let notificationNames: [Notification.Name]
    let action: () -> Void

    func body(content: Content) -> some View {
        notificationNames.reduce(AnyView(content)) { partial, name in
            AnyView(partial.onReceive(NotificationCenter.default.publisher(for: name)) { _ in
                action()
            })
        }
    }
}

// MARK: - Event Handler

extension AudioRootView {
    @MainActor
    private func reloadContainer() {
        initGeneration += 1
        let generation = initGeneration
        isInitializing = true
        container = nil
        error = nil

        guard hasStorageLocation() else {
            isInitializing = false
            error = AudioPluginError.initialization(reason: AudioRootErrorPresentation.storageMissingReason)
            return
        }

        let requestedDatabaseURL: URL
        do {
            requestedDatabaseURL = try databaseURL()
        } catch {
            isInitializing = false
            self.error = AudioPluginError.initialization(reason: error.localizedDescription)
            return
        }

        Task { @MainActor in
            let result = await Task.detached(priority: .userInitiated) {
                do {
                    return Result<ModelContainer, AudioContainerLoadError>.success(
                        try AudioConfigRepo.getContainer(databaseURL: requestedDatabaseURL)
                    )
                } catch {
                    return Result<ModelContainer, AudioContainerLoadError>.failure(
                        .message(error.localizedDescription)
                    )
                }
            }.value

            guard generation == initGeneration else { return }

            switch result {
            case .success(let container):
                self.container = container
                self.error = nil
            case .failure(.message(let message)):
                os_log(.error, "\(self.t)初始化失败: \(message)")
                self.container = nil
                self.error = AudioPluginError.initialization(reason: message)
            }
            self.isInitializing = false
        }
    }

    /// 处理存储位置变化事件
    ///
    /// 当用户切换存储位置（本地/iCloud）时触发，提示用户存储位置已变化。
    func handleStorageLocationChanged() {
        if Self.verbose {
            os_log("\(self.t)📂 存储位置已变化")
        }

        alert_info(String(localized: "Storage location has changed", bundle: .module))
    }

    /// 处理视图消失事件
    ///
    /// 当视图从屏幕上消失时触发，用于清理资源。
    func handleOnDisappear() {
        if Self.verbose {
            os_log("\(self.t)👋 视图已消失")
        }
    }
}
