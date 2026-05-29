import MagicKit
import OSLog
import SwiftUI

/// 预览视图
/// 用于在 Xcode Preview 中展示 MagicPlayMan 的完整功能
public struct MagicPlayManPreviewView: View {
    // MARK: - Properties

    @StateObject var playMan: MagicPlayMan
    @State var selectedSampleName: String?

    // MARK: - Initialization

    public init(
        cacheDirectory: URL? = nil
    ) {
        // 显式指定使用中文
        _playMan = StateObject(wrappedValue: MagicPlayMan(
            cacheDirectory: cacheDirectory,
            verbose: true,
            locale: Locale(identifier: "zh_CN")
        ))
    }

    // MARK: - Event Observation

    private func setupEventObservation() {
        playMan.subscribe(
            name: "PreviewView",
            onTrackFinished: { [weak playMan] track in
                if playMan?.verbose == true {
                    os_log("\(playMan?.t ?? "")观察到事件：单曲播放完成 - \(track.title)")
                }
            },
            onPlaybackFailed: { [weak playMan] error in
                if playMan?.verbose == true {
                    os_log("\(playMan?.t ?? "")观察到事件：播放失败 - \(error)")
                }
            },
            onBufferingStateChanged: { [weak playMan] isBuffering in
                if playMan?.verbose == true {
                    os_log("\(playMan?.t ?? "")观察到事件：缓冲状态变化 - \(isBuffering ? "开始缓冲" : "缓冲完成")")
                }
            },
            onStateChanged: { [weak playMan] state in
                if playMan?.verbose == true {
                    os_log("\(playMan?.t ?? "")观察到事件：播放状态变化 - \(state.stateText)")
                }
            },
            onNextRequested: { [weak playMan] asset in
                if playMan?.verbose == true {
                    os_log("\(playMan?.t ?? "")观察到事件：请求下一个 - \(asset.absoluteString)")
                }
            },
            onLikeStatusChanged: { [weak playMan] asset, isLiked in
                if playMan?.verbose == true {
                    os_log("\(playMan?.t ?? "")观察到事件：喜欢状态变化 - \(asset.title) \(isLiked ? "被喜欢" : "取消喜欢")")
                }
            },
            onPlayModeChanged: { [weak playMan] newMode in
                if playMan?.verbose == true {
                    os_log("\(playMan?.t ?? "")观察到事件：播放模式变化 - \(playMan?.playMode.rawValue ?? "未知") -> \(newMode.rawValue)")
                }
            }
        )
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            toolbarView

            mainContentArea
                .withMagicToast()
        }
        .onAppear {
            setupEventObservation()
        }
        .shadowNone()
        .localization(_playMan.wrappedValue.localization)
        .infinite()
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicPlayManPreviewView()
        .frame(width: 600, height: 700)
}
