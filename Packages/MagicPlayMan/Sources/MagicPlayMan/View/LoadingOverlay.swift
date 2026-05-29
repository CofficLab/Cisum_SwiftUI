import SwiftUI

struct LoadingOverlay: View {
    let state: PlaybackState.LoadingState
    let assetTitle: String

    @Environment(\.localization) private var loc

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            switch state {
            case let .downloading(progress):
                downloadingProgress(progress)
            case .buffering:
                loadingIndicator(loc.buffering)
            case .preparing:
                loadingIndicator(loc.preparing)
            case .connecting:
                loadingIndicator(loc.connecting)
            }
        }
    }

    private func downloadingProgress(_ progress: Double) -> some View {
        VStack(spacing: 16) {
            ProgressView(
                "\(loc.downloading) \(assetTitle)",
                value: progress,
                total: 1.0
            )
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private func loadingIndicator(_ message: String) -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingOverlay(state: .connecting, assetTitle: "Test Song")
            .frame(height: 200)

        LoadingOverlay(state: .downloading(0.45), assetTitle: "Test Song")
            .frame(height: 200)

        LoadingOverlay(state: .buffering, assetTitle: "Test Song")
            .frame(height: 200)
    }
    .padding()
}
