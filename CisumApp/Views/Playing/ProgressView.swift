import PluginRegistry
import SwiftUI

struct PlayingProgressView: View {
    @Environment(\.demoMode) var isDemoMode
    @Environment(\.downloadingMode) var isDownloadingMode
    @EnvironmentObject var playMan: PlayMan
    @LumiTheme private var appTheme
    @LumiMotionPreferenceReader private var motionPreference

    var body: some View {
        if isDownloadingMode {
            downloadingProgressView
        } else if isDemoMode {
            demoProgressView
        } else {
            playMan.makeProgressView()
        }
    }

    // MARK: 下载中场景的进度条

    private var downloadingProgressView: some View {
        VStack(alignment: .center, spacing: 8) {
            // 进度条（禁用状态，位于起点）
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景条
                    RoundedRectangle(cornerRadius: 2)
                        .fill(appTheme.textTertiary.opacity(0.18))

                    // 进度（起点，即进度为0）
                    RoundedRectangle(cornerRadius: 2)
                        .fill(appTheme.primary.opacity(0.28))
                        .frame(width: geometry.size.width * downloadProgress)
                        .animation(
                            LumiMotion.enabled(LumiMotion.statusPresentation, preference: motionPreference),
                            value: downloadProgress
                        )
                }
            }
            .frame(height: 4)

            // 时间标签（显示为未知）
            HStack {
                Text("--:--")
                    .font(.system(size: 12))
                    .foregroundColor(appTheme.textTertiary)

                Spacer()

                Text(downloadPercentText)
                    .font(.system(size: 12))
                    .foregroundColor(appTheme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: 演示模式的进度条

    private var demoProgressView: some View {
        VStack(alignment: .center, spacing: 8) {
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景条
                    RoundedRectangle(cornerRadius: 2)
                        .fill(appTheme.textTertiary.opacity(0.18))

                    // 进度
                    RoundedRectangle(cornerRadius: 2)
                        .fill(appTheme.primary)
                        .frame(width: geometry.size.width * 0.35)
                }
            }
            .frame(height: 4)

            // 时间标签
            HStack {
                Text("1:24")
                    .font(.system(size: 12))
                    .foregroundColor(appTheme.textTertiary)

                Spacer()

                Text("3:45")
                    .font(.system(size: 12))
                    .foregroundColor(appTheme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var downloadProgress: CGFloat {
        if case .loading(.downloading(let progress)) = playMan.state {
            return CGFloat(normalizedDownloadProgress(progress))
        }

        return 0
    }

    private var downloadPercentText: String {
        if case .loading(.downloading(let progress)) = playMan.state {
            return "\(Int(normalizedDownloadProgress(progress) * 100))%"
        }

        return "--"
    }

    private func normalizedDownloadProgress(_ progress: Double) -> Double {
        min(max(progress, 0), 1)
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
