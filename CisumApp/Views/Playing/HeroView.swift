import CisumUI
import MagicPlayMan
import OSLog
import SwiftUI

struct HeroView: View, SuperLog {
    nonisolated static let emoji = "🎭"
    nonisolated static let verbose = false

    @EnvironmentObject var app: AppVM
    @EnvironmentObject var playMan: PlayMan
    @Environment(\.demoMode) var isDemoMode
    @Environment(\.downloadingMode) var isDownloadingMode
    @LumiTheme private var appTheme
    @LumiMotionPreferenceReader private var motionPreference

    private let titleViewHeight: CGFloat = 60

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                if shouldShowAlbum(geo) {
                    if isDownloadingMode {
                        // 下载中场景: 显示圆形进度
                        downloadingAlbumView
                            .frame(maxWidth: .infinity)
                            .frame(height: getAlbumHeight(geo))
                            .clipped()
                    } else if isDemoMode {
                        // Demo mode: 显示静态演示封面
                        demoAlbumView
                            .frame(width: geo.size.width * 0.6)
                            .frame(height: getAlbumHeight(geo))
                    } else {
                        playMan.makeHeroView(verbose: Self.verbose, avatarShape: .roundedRectangle(cornerRadius: 8))
                            .frame(maxWidth: .infinity)
                            .frame(height: getAlbumHeight(geo))
                    }
                }

                TitleView()
                    .frame(maxWidth: .infinity)
                    .frame(height: titleViewHeight)
            }
            .cisumInfinite()
        }
        .ignoresSafeArea(edges: Config.isDesktop ? .horizontal : .all)
    }
}

// MARK: - View

extension HeroView {
    // 下载中场景的圆形进度视图
    private var downloadingAlbumView: some View {
        ZStack {
            // 背景圆形
            Circle()
                .stroke(
                    appTheme.textTertiary.opacity(0.18),
                    lineWidth: 8
                )
                .frame(width: 200, height: 200)

            // 进度环形指示（下载中旋转）
            Circle()
                .trim(from: 0, to: downloadProgress)
                .stroke(
                    appTheme.primary,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(
                    LumiMotion.enabled(LumiMotion.statusPresentation, preference: motionPreference),
                    value: downloadProgress
                )

            // 中心文字
            VStack(spacing: 8) {
                Text(downloadPercentText)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(appTheme.textPrimary)

                Text(playMan.state.localizedStateText(localization: playMan.localization))
                    .font(.system(size: 14))
                    .foregroundColor(appTheme.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appTheme.elevatedSurface.opacity(0.55))
    }

    // Demo mode 的静态演示封面
    private var demoAlbumView: some View {
        LogoView()
    }
}

// MARK: - Private Helpers

extension HeroView {
    // 计算专辑封面高度
    private func getAlbumHeight(_ geo: GeometryProxy) -> CGFloat {
        // 总高度减去标题高度就是封面可用空间
        return max(0, geo.size.height - titleViewHeight)
    }

    private func shouldShowAlbum(_ geo: GeometryProxy) -> Bool {
        !app.rightAlbumVisible && geo.size.height > Config.minHeightToShowAlbum
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

#Preview("App Demo") {
    ContentView()
        .inRootView()
        .inDemoMode()
        .withDebugBar()
}
