import Foundation
import CisumUI
import OSLog
import SwiftUI
import PluginAudio

public struct AudioDBRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { "🎵" }
    public nonisolated static var verbose: Bool { false }

    @Environment(\.audioDBDependencies) private var dependencies
    private let isDemoMode: Bool

    private var content: Content

    public init(isDemoMode: Bool, @ViewBuilder content: () -> Content) {
        self.isDemoMode = isDemoMode
        self.content = content()
    }

    public var body: some View {
        if isDemoMode {
            content
        } else {
            content
                .task {
                    await checkAudioRepo()
                }
                .onDBUpdated(perform: handleDBUpdated)
        }
    }
}

// MARK: - Private Helpers

extension AudioDBRootView {
    /// 检查 AudioRepo 是否为空，如果为空则显示数据库视图
    @MainActor
    private func checkAudioRepo() async {
        guard !isDemoMode else { return }

        guard let repo = dependencies.audioRepo() else {
            dependencies.showDBView()
            return
        }

        let count = await repo.getTotalCount()
        
        if count == 0 {
            dependencies.showDBView()
        }
    }
}

// MARK: - Event Handler

extension AudioDBRootView {
    /// 处理数据库更新事件
    func handleDBUpdated(_ notification: Notification) {
        Task {
            await checkAudioRepo()
        }
    }
}
