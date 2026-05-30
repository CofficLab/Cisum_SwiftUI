import SwiftUI
import MagicKit

struct DownloadButtonView: View, SuperLog {
    nonisolated static let emoji: String = "🐯"
    
    let url: URL
    let size: CGFloat
    let showLabel: Bool
    let destination: URL?
    
    @State var isDownloading: Bool
    @State var progress: Double
    @State var error: Error?
    
    init(
        url: URL,
        size: CGFloat = 28,
        showLabel: Bool = false,
        destination: URL? = nil,
        isDownloading: Bool = false,
        progress: Double = 0,
        error: Error? = nil
    ) {
        self.url = url
        self.size = size
        self.showLabel = showLabel
        self.destination = destination
        self._isDownloading = State(initialValue: isDownloading)
        self._progress = State(initialValue: progress)
        self._error = State(initialValue: error)
    }
    
    private var buttonIcon: String {
        if url.isDownloaded {
            return .iconCheckmark
        } else if url.checkIsICloud(verbose: false) {
            return .iconICloudDownloadAlt
        } else {
            return .iconDownload
        }
    }

    private var buttonLabel: String {
        if url.isDownloaded {
            return "已下载"
        } else if url.checkIsICloud(verbose: false) {
            return "从 iCloud 下载"
        } else {
            return "下载"
        }
    }
    
    private var buttonDisabled: Bool {
        url.isDownloaded || isDownloading
    }

    private var displayedProgress: Double {
        normalizedProgress(progress)
    }
    
    var body: some View {
        VStack {
            if isDownloading {
                ProgressView(value: displayedProgress, total: 100)
                    .progressViewStyle(.circular)
                    .frame(width: size * 0.8, height: size * 0.8)
                    .frame(width: size, height: size)
            } else {
                Button(action: handleButtonTap) {
                    HStack(spacing: 4) {
                        Image(systemName: buttonIcon)
                        if showLabel {
                            Text(buttonLabel)
                        }
                    }
                    .frame(width: size, height: size)
                }
                .disabled(buttonDisabled)
                .symbolEffect(.bounce, value: url.isDownloaded)
            }
            
            if let error = error {
                Text(error.localizedDescription)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .frame(maxWidth: 200)
                    .multilineTextAlignment(.center)
            }
        }
        .animation(.smooth, value: isDownloading)
        .animation(.smooth, value: error != nil)
    }
    
    private func handleButtonTap() {
        Task {
            isDownloading = true
            error = nil
            progress = 0
            
            do {
                if let destination = destination {
                    try await url.copyTo(destination, caller: self.className) { newProgress in
                        progress = normalizedProgress(newProgress)
                    }
                } else {
                    try await url.download(reason: "MagicKit.DownloadButtonView") { newProgress in
                        progress = normalizedProgress(newProgress)
                    }
                }
            } catch {
                self.error = error
            }
            
            isDownloading = false
        }
    }

    private func normalizedProgress(_ value: Double) -> Double {
        if value.isNaN || !value.isFinite {
            return 0
        }

        let percent = value <= 1 ? value * 100 : value
        return min(max(percent, 0), 100)
    }
}
