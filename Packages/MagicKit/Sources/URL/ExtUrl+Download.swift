import Foundation
import OSLog

public extension URL {
    enum DownloadMethod {
        case polling(updateInterval: TimeInterval = 0.5)
        case query
    }

    func download(
        verbose: Bool = false,
        reason: String,
        method: DownloadMethod = .polling(),
        onProgress: ((Double) -> Void)? = nil
    ) async throws {
        guard checkIsICloud(verbose: false), isNotDownloaded else {
            if verbose {
                os_log("\(self.t)(\(reason)) file does not need iCloud download")
            }
            onProgress?(1)
            return
        }

        if verbose {
            os_log("\(self.t)(\(reason)) start iCloud download: \(lastPathComponent)")
        }

        try FileManager.default.startDownloadingUbiquitousItem(at: self)

        guard let onProgress else { return }

        let interval: TimeInterval
        switch method {
        case let .polling(updateInterval):
            interval = updateInterval
        case .query:
            interval = 0.5
        }

        while !isDownloaded {
            let progress = getDownloadProgressSnapshot(verbose: false)
            await MainActor.run {
                onProgress(progress)
            }

            if progress >= 1 {
                break
            }

            try await Task.sleep(nanoseconds: UInt64(max(interval, 0.1) * 1_000_000_000))
        }

        await MainActor.run {
            onProgress(1)
        }
    }
}
