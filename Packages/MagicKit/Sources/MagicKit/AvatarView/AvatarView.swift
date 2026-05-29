import Combine
import os
import SwiftUI
import UniformTypeIdentifiers

/// 一个用于展示文件缩略图的头像视图组件
///
/// `AvatarView` 是一个多功能的视图组件，专门用于展示文件的缩略图和状态。
/// 它支持多种文件类型，包括图片、视频、音频等，并能自动处理不同的显示状态。
///
/// # 功能特性
/// - 自动生成文件缩略图
/// - 支持多种文件类型
/// - 实时显示下载进度
/// - 错误状态可视化
/// - 可自定义外观
///
/// # 示例代码
/// ```swift
/// // 基础用法
/// AvatarView(url: fileURL)
///
/// // 自定义形状
/// AvatarView(url: fileURL)
///     .magicShape(.roundedRectangle(cornerRadius: 8))
/// ```
public struct AvatarView: View, SuperLog {
    // MARK: - Properties

    /// 表情符号标识符
    public static let emoji = "🚉"

    /// 视图状态管理器，管理缩略图、加载状态和错误状态
    @StateObject var state: ViewState

    /// 全局下载进度订阅
    @State private var progressCancellable: AnyCancellable? = nil

    /// 文件的URL
    let url: URL

    /// 是否启用详细日志输出
    let verbose: Bool

    /// 视图的形状样式
    var shape: AvatarViewShape = .circle

    /// 是否监控下载进度（仅对iCloud文件有效）
    var monitorDownload: Bool = true

    /// 视图尺寸
    var size: CGSize = CGSize(width: 40, height: 40)

    /// 视图背景色
    var backgroundColor: Color = .blue.opacity(0.1)

    // MARK: - Computed Properties

    /// 当前的下载进度
    private var downloadProgress: Double {
        state.autoDownloadProgress
    }

    /// 是否正在下载
    private var isDownloading: Bool {
        downloadProgress > 0 && downloadProgress <= 1
    }

    // MARK: - Initialization

    /// 创建一个新的头像视图
    /// - Parameters:
    ///   - url: 要显示的文件URL
    ///   - size: 视图的尺寸，默认为 40x40
    ///   - verbose: 是否启用详细日志输出
    public init(url: URL, size: CGSize = CGSize(width: 40, height: 40), verbose: Bool = false) {
        self.url = url
        self.size = size
        self.verbose = verbose

        // 计算初始错误状态
        let initialError: ViewError? = {
            if url.isFileURL && url.isNotFileExist {
                return .fileNotFound
            } else if !url.isFileURL && !url.isNetworkURL {
                return .invalidURL
            }
            return nil
        }()

        // 一次性初始化 StateObject，避免访问未安装的 property wrapper
        _state = StateObject(wrappedValue: ViewState(error: initialError))
    }

    // MARK: - Body

    public var body: some View {
        Group {
            if isDownloading && downloadProgress < 1 {
                DownloadingView(
                    progress: downloadProgress,
                    shape: shape,
                    size: size,
                    backgroundColor: backgroundColor
                )
            } else if let thumbnail = state.thumbnail {
                ThumbnailView(
                    image: thumbnail,
                    isSystemIcon: state.isSystemIcon,
                    shape: shape,
                    size: size,
                    backgroundColor: backgroundColor
                )
            } else if let error = state.error {
                ErrorView(
                    error: error,
                    url: url,
                    shape: shape,
                    size: size,
                    backgroundColor: backgroundColor
                )
            } else if state.isLoading {
                LoadingView(
                    shape: shape,
                    size: size,
                    backgroundColor: backgroundColor
                )
            } else {
                DefaultIconView(
                    url: url,
                    shape: shape,
                    size: size,
                    backgroundColor: backgroundColor
                )
            }
        }
        .task(id: url) { await onAppear() }
        .onChange(of: state.needsReload) {
            // 下载完成后触发重新加载缩略图
            if state.needsReload {
                state.clearNeedsReload()
                Task { await loadThumbnail() }
            }
        }
        .onDisappear(perform: onDisappear)
    }
}

// MARK: - Actions

extension AvatarView {
    /// 异步加载文件的缩略图
    /// 根据文件类型和状态决定是否需要生成或加载缩略图
    private func loadThumbnail() async {
        let hasThumbnail = state.thumbnail != nil

        if state.isLoading {
            return
        }

        // 显式捕获所有需要的值，避免捕获 self
        let capturedUrl = url
        let capturedSize = size
        let capturedState = state

        // 使用后台任务队列
        await Task.detached(priority: .utility) { [hasThumbnail] in
            if hasThumbnail && capturedUrl.checkIsDownloaded() {
                return
            }

            if capturedUrl.checkIsDownloading(verbose: false) {
                return
            }

            await capturedState.setLoading(true)

            do {
                let result = try await capturedUrl.thumbnail(
                    size: capturedSize,
                    verbose: false,
                    reason: self.className + ".loadThumbnail"
                )

                if let result = result,
                   let image = result.toSwiftUIImage() {
                    await capturedState.setThumbnail(image, isSystemIcon: result.isSystemIcon)
                    await capturedState.setError(nil)
                }
            } catch URLError.cancelled {
                os_log("\(Self.t)缩略图加载被取消")
            } catch {
                os_log(.error, "\(Self.t)❌ 加载缩略图失败: \(error.localizedDescription)")
                let viewError: ViewError
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                        viewError = .downloadFailed(urlError)
                    case .fileDoesNotExist:
                        viewError = .fileNotFound
                    default:
                        viewError = .thumbnailGenerationFailed(urlError)
                    }
                } else {
                    viewError = .thumbnailGenerationFailed(error)
                }

                await capturedState.setError(viewError)
            }

            await capturedState.setLoading(false)
        }.value
    }

    /// 设置下载进度监控器
    /// 仅对iCloud文件启动监控
    private func setupDownloadMonitor(verbose: Bool) async {
        guard monitorDownload else {
            return
        }

        // 显式捕获需要的值
        let capturedUrl = url
        let capturedState = state

        // 在后台线程检查是否为 iCloud 文件
        let isICloud = await Task.detached(priority: .utility) {
            capturedUrl.checkIsICloud(verbose: false)
        }.value

        guard isICloud else {
            return
        }

        // ⚠️ 重要：先取消旧订阅，再创建新订阅，避免引用计数混乱
        if let oldCancellable = progressCancellable {
            oldCancellable.cancel()
            progressCancellable = nil
            await AvatarDownloadMonitor.shared.unsubscribe(url: capturedUrl, verbose: verbose)
        }

        // 创建新订阅
        let cancellable = await AvatarDownloadMonitor.shared
            .subscribe(url: capturedUrl, verbose: verbose)
            .receive(on: DispatchQueue.main)
            .sink { [capturedState, capturedUrl] progress in
                // 更新进度状态
                capturedState.setProgress(progress)

                // 如果下载失败
                if progress < 0 {
                    os_log("\(Self.t)❌ 下载失败: \(capturedUrl.lastPathComponent)")
                    capturedState.setError(ViewError.downloadFailed(nil))
                }

                // 如果下载完成
                if progress >= 1.0 {
                    capturedState.markNeedsReload()
                }
            }

        progressCancellable = cancellable
    }
}

// MARK: - Event Handler

extension AvatarView {
    /// 处理视图出现时的事件
    /// 优化策略：对于已下载/本地文件跳过延迟直接加载（因为会从缓存读取）
    private func onAppear() async {
        // 下载进度监控
        await setupDownloadMonitor(verbose: self.verbose)

        // 加载缩略图
        if state.error == nil, state.thumbnail == nil {
            await loadThumbnail()
        }
    }

    /// 处理视图消失时的事件
    /// 取消所有订阅，释放资源
    private func onDisappear() {
        // 先清空本地引用，防止重复取消
        let oldCancellable = progressCancellable
        progressCancellable = nil

        // 取消 Combine 订阅
        oldCancellable?.cancel()

        // 取消全局下载监控订阅（使用 Task 而非 detached，确保在主线程执行）
        let capturedUrl = url
        Task { @MainActor in
            await AvatarDownloadMonitor.shared.unsubscribe(url: capturedUrl, verbose: self.verbose)
        }
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("基础样式") {
        AvatarBasicPreview()
            .frame(width: 500, height: 600)
    }
#endif
