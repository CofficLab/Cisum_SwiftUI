import MagicKit
import SwiftUI

extension MagicPlayManPreviewView {
    /// 下载进度视图
    func downloadingProgress(_ progress: Double, title: String) -> some View {
        VStack(spacing: 16) {
            ProgressView(
                "\(playMan.localization.downloading) \(title)",
                value: progress,
                total: 1.0
            )
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    /// 加载指示器视图
    func loadingIndicator(_ message: String) -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicPlayManPreviewView()
        .frame(width: 600, height: 700)
}
