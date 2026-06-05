import Foundation
import CisumUI
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

public struct AudioRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { "📢" }
    public nonisolated static var verbose: Bool { false }

    @State private var error: AudioPluginError? = nil
    @State private var container: ModelContainer? = nil
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
        let initialState = Self.makeContainer(
            databaseURL: databaseURL,
            hasStorageLocation: hasStorageLocation
        )
        self._container = State(initialValue: initialState.container)
        self._error = State(initialValue: initialState.error)

        if Self.verbose {
            os_log("\(Self.t)初始化完成")
        }
    }

    public var body: some View {
        Group {
            if error != nil {
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
    private static func makeContainer(
        databaseURL: @MainActor () throws -> URL,
        hasStorageLocation: @MainActor () -> Bool
    ) -> (container: ModelContainer?, error: AudioPluginError?) {
        guard hasStorageLocation() else {
            if Self.verbose {
                os_log("\(Self.t)放弃初始化，因为: Storage 未找到")
            }
            return (nil, AudioPluginError.initialization(reason: AudioRootErrorPresentation.storageMissingReason))
        }

        do {
            let container = try AudioConfigRepo.getContainer(databaseURL: databaseURL())
            return (container, nil)
        } catch {
            os_log(.error, "\(Self.t)初始化失败: \(error.localizedDescription)")
            return (nil, AudioPluginError.initialization(reason: error.localizedDescription))
        }
    }

    private func reloadContainer() {
        let nextState = Self.makeContainer(
            databaseURL: databaseURL,
            hasStorageLocation: hasStorageLocation
        )
        container = nextState.container
        error = nextState.error
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
