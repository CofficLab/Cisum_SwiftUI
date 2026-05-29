import MagicKit
import SwiftUI

extension MagicPlayManPreviewView {
    /// 主内容区域
    var mainContentArea: some View {
        VStack(spacing: 0) {
            mainContent
            controlsSection
        }
        .background(LinearGradient.aurora.opacity(0.1))
    }

    /// 主内容视图
    var mainContent: some View {
        ZStack {
            playMan.makeMediaView()

            if case let .loading(loadingState) = playMan.state, let asset = playMan.currentAsset {
                LoadingOverlay(state: loadingState, assetTitle: asset.title)
            }

            if case let .failed(error) = playMan.state, let assetURL = playMan.currentAsset {
                ErrorOverlay(
                    error: error,
                    asset: assetURL
                ) {
                    Task {
                        await playMan.play(assetURL, reason: "PreviewView")
                    }
                }
            }
        }
        .infinite()
        .background(LinearGradient.winter)
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicPlayManPreviewView()
        .frame(width: 600, height: 700)
}
