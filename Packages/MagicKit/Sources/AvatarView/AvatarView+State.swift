import SwiftUI

extension AvatarView {
    /// 头像视图的状态管理
    @MainActor public final class ViewState: ObservableObject {
        /// 缩略图
        @Published public var thumbnail: Image?

        /// 是否为系统图标
        @Published public var isSystemIcon: Bool = false

        /// 错误状态
        @Published public var error: Error?

        /// 加载状态
        @Published public var isLoading = false

        /// 自动下载进度
        @Published public var autoDownloadProgress: Double = 0

        /// 标记是否需要重新加载缩略图（下载完成后触发）
        @Published public var needsReload = false

        /// 创建一个新的视图状态实例
        /// - Parameter error: 初始错误状态，默认为 nil
        public init(error: Error? = nil) {
            self.error = error
        }

        /// 重置所有状态
        public func reset() {
            thumbnail = nil
            isSystemIcon = false
            error = nil
            isLoading = false
            autoDownloadProgress = 0
        }

        /// 设置加载状态
        public func setLoading(_ loading: Bool) {
            isLoading = loading
        }

        /// 设置错误状态
        public func setError(_ error: Error?) {
            self.error = error
        }

        /// 设置缩略图
        public func setThumbnail(_ image: Image?) {
            self.thumbnail = image
        }

        /// 设置缩略图和图标类型
        public func setThumbnail(_ image: Image?, isSystemIcon: Bool) {
            self.thumbnail = image
            self.isSystemIcon = isSystemIcon
        }

        /// 设置下载进度
        public func setProgress(_ progress: Double) {
            self.autoDownloadProgress = progress
        }

        /// 标记下载完成，需要重新加载缩略图
        public func markNeedsReload() {
            reset()
            needsReload = true
        }

        /// 清除重新加载标记
        public func clearNeedsReload() {
            needsReload = false
        }
    }
}