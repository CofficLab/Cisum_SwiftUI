import SwiftUI

// MARK: - 动画时长
extension DesignTokens {
    /// 动画时长令牌 - 定义交互动画的标准时间
    enum Duration {
        /// 微交互 (0.15s)
        static let micro: TimeInterval = 0.15
        /// 标准过渡 (0.20s)
        static let standard: TimeInterval = 0.20
        /// 中等动画 (0.30s)
        static let moderate: TimeInterval = 0.30
        /// 缓慢动画 (0.50s)
        static let slow: TimeInterval = 0.50
    }
}
