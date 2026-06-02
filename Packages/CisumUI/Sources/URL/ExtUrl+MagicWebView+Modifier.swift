import SwiftUI

public extension MagicWebView {
    /// 设置是否显示日志视图
    /// - Parameter show: 是否显示
    /// - Returns: 修改后的视图
    func showLogView(_ show: Bool = true) -> MagicWebView {
        MagicWebView(
            url: url,
            showLogView: show,
            onLoadComplete: onLoadComplete,
            onJavaScriptError: onJavaScriptError,
            onCustomMessage: onCustomMessage
        )
    }
    
    /// 跳转到新的URL
    /// - Parameter url: 目标URL
    /// - Returns: 修改后的视图
    func goto(_ url: URL) -> MagicWebView {
        MagicWebView(
            url: url,
            showLogView: true,
            onLoadComplete: onLoadComplete,
            onJavaScriptError: onJavaScriptError,
            onCustomMessage: onCustomMessage
        )
    }
    
    /// 设置是否启用详细日志模式
    /// - Parameter enabled: 是否启用详细日志
    /// - Returns: 修改后的视图
    func verboseMode(_ enabled: Bool = true) -> MagicWebView {
        var view = self
        view.isVerboseMode = enabled
        return view
    }
}

#if DEBUG
#Preview("WebView Demo") {
    MagicWebViewDemo()
        .frame(height: 800)
}
#endif
