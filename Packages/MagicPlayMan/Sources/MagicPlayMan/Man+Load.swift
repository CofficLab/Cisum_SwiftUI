import AVFoundation
import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI
import CisumUI

enum MagicPlayManDownloadRequestPolicy {
    static func shouldApplyResult(requestedAsset: URL, currentAsset: URL?) -> Bool {
        requestedAsset == currentAsset
    }

    static func shouldFinishDownload(requestedAsset: URL, currentAsset: URL?) -> Bool {
        requestedAsset == currentAsset
    }
}

extension MagicPlayMan {
    /// 下载并缓存资源
    /// - Parameters:
    ///   - url: 要下载的资源 URL
    ///   - reason: 更新原因
    ///   - onFinished: 下载完成后的回调（主线程执行）
    @MainActor
    func downloadAndCache(_ url: URL, reason: String, onFinished: (() -> Void)? = nil) {
        guard cache != nil else {
            onFinished?()
            return
        }

        if url.isDownloaded {
            onFinished?()
            return
        }

        self.setState(.loading(.downloading(0)), reason: "\(reason).\(self.className).downloadAndCache")

        // 添加节流控制
        let progressSubject = CurrentValueSubject<Double, Never>(0)
        let progressObserver = url.onDownloading(verbose: self.verbose, caller: self.className + ".downloadAndCache") { progress in
            progressSubject.send(progress)
        }

        // 使用 Combine 的 throttle 操作符限制更新频率
        let progressUpdateObserver = progressSubject
            .throttle(for: .milliseconds(1000), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] progress in
                guard let self = self else { return }
                Task { @MainActor in
                    // 只有在加载状态时才更新下载进度，避免与播放状态冲突
                    if case .loading = self.state,
                       MagicPlayManDownloadRequestPolicy.shouldApplyResult(
                           requestedAsset: url,
                           currentAsset: self.currentURL
                       ) {
                        self.setState(.loading(.downloading(progress)), reason: "\(reason).\(self.className).downloadProgress")
                    }
                }
            }

        cancellables.insert(progressUpdateObserver)

        // 监听下载完成
        let finishObserver = url.onDownloadFinished(verbose: self.verbose, caller: self.className) { [weak self] in
            guard let self = self else { return }
            Task { @MainActor in
                guard MagicPlayManDownloadRequestPolicy.shouldFinishDownload(
                    requestedAsset: url,
                    currentAsset: self.currentURL
                ), self.currentDownloadObservers != nil else {
                    if self.verbose {
                        os_log("\(self.t)⚠️ URL changed during download completion, ignoring stale result for: \(url.title)")
                    }
                    return
                }

                self.cleanupDownloadObservers()
                // 下载完成后执行回调
                onFinished?()
            }
        }

        // 存储下载监听器引用
        self.setCurrentDownloadObservers((progressObserver, finishObserver))

        // 开始下载
        Task {
            do {
                try await url.ensureLocalAvailability()

                await MainActor.run {
                    guard MagicPlayManDownloadRequestPolicy.shouldFinishDownload(
                        requestedAsset: url,
                        currentAsset: self.currentURL
                    ), self.currentDownloadObservers != nil else {
                        if self.verbose {
                            os_log("\(self.t)⚠️ URL changed after ensuring local availability, ignoring stale result for: \(url.title)")
                        }
                        return
                    }

                    self.cleanupDownloadObservers()
                    onFinished?()
                }
            } catch {
                await MainActor.run {
                    guard MagicPlayManDownloadRequestPolicy.shouldApplyResult(
                        requestedAsset: url,
                        currentAsset: self.currentURL
                    ) else {
                        if self.verbose {
                            os_log("\(self.t)⚠️ URL changed during download failure, ignoring error for: \(url.title)")
                        }
                        return
                    }

                    // 下载失败时清理监听器
                    self.cleanupDownloadObservers()
                    self.setState(.failed(.networkError(error.localizedDescription)), reason: "\(reason).\(self.className).downloadAndCache")
                }
            }
        }
    }

    /// 清理下载监听器
    @MainActor
    private func cleanupDownloadObservers() {
        if let (progressObserver, finishObserver) = currentDownloadObservers {
            progressObserver.cancel()
            finishObserver.cancel()
            setCurrentDownloadObservers(nil)
        }
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicPlayMan.getPreviewView()
}
