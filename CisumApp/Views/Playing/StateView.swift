import CisumUI
import MagicPlayMan
import OSLog
import SwiftData
import SwiftUI

struct StateView: View, SuperLog, SuperThread {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var messageManager: StateProvider
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var p: PluginProvider
    @Environment(\.demoMode) var isDemoMode
    @LumiTheme private var appTheme
    @LumiMotionPreferenceReader private var motionPreference

    nonisolated static let emoji = "🖥️"
    nonisolated static let verbose = false

    var asset: URL? { playMan.asset }
    var font: Font { asset == nil ? .title3 : .callout }

    /// 驱动状态区显隐动画的标识
    private var stateAnimationToken: String {
        [
            messageManager.stateMessage,
            playMan.state.isDownloading ? playMan.state.localizedStateText(localization: playMan.localization) : "",
            playMan.currentError.map { String(describing: $0) } ?? "",
        ].joined(separator: "|")
    }

    var body: some View {
        if isDemoMode {
            EmptyView()
        } else {
            VStack(spacing: 10) {
                // 内部状态消息
                if messageManager.stateMessage.count > 0 {
                    makeInfoView(messageManager.stateMessage)
                        .appStatusPresentationTransition(preference: motionPreference)
                }

                if playMan.state.isDownloading {
                    makeInfoView(playMan.state.localizedStateText(localization: playMan.localization))
                        .appStatusPresentationTransition(preference: motionPreference)
                }

                // 播放过程中出现的错误
                if let e = playMan.currentError {
                    makeErrorView(e)
                        .appStatusPresentationTransition(preference: motionPreference)
                }

                // 各个插件提供的 state view
                ForEach(p.plugins, id: \.id) { plugin in
                    plugin.addStateView(currentSceneName: p.currentSceneName)
                }
            }
            .animation(
                LumiMotion.enabled(LumiMotion.statusPresentation, preference: motionPreference),
                value: stateAnimationToken
            )
        }
    }
}

// MARK: - View

extension StateView {
    func makeInfoView(_ i: String) -> some View {
        HStack {
            Image.cisumInfo
                .foregroundStyle(appTheme.primary)
            Text(i)
                .foregroundStyle(appTheme.textSecondary)
        }
        .font(font)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(appTheme.elevatedSurface.opacity(0.72), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(appTheme.divider, lineWidth: 1)
        )
    }

    func makeErrorView(_ e: Error) -> some View {
        HStack {
            Image.cisumInfo
                .foregroundStyle(appTheme.error)
            // 如果是 PlaybackError，使用本地化描述
            if let playbackError = e as? PlaybackState.PlaybackError {
                Text(playbackError.localizedDescription(localization: playMan.localization))
                    .foregroundStyle(appTheme.textSecondary)
            } else {
                Text(e.localizedDescription)
                    .foregroundStyle(appTheme.textSecondary)
            }
        }
        .font(font)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(appTheme.error.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(appTheme.error.opacity(0.18), lineWidth: 1)
        )
    }
}

// MARK: - Action

extension StateView {
}

// MARK: - Setter

extension StateView {
}

// MARK: - Event Handler

extension StateView {
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
