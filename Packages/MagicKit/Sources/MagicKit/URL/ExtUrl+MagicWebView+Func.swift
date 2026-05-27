import SwiftUI

public extension URL {
    /// 创建用于展示该URL的WebView
    /// - Parameters:
    ///   - onLoadComplete: 网页加载完成时的回调
    ///   - onJavaScriptError: JS错误时的回调
    ///   - onCustomMessage: 自定义消息回调
    /// - Returns: 包含该URL内容的WebView
    func makeWebView(
        onLoadComplete: ((Error?) -> Void)? = nil,
        onJavaScriptError: ((String, Int, String) -> Void)? = nil,
        onCustomMessage: ((Any) -> Void)? = nil
    ) -> MagicWebView {
        MagicWebView(
            url: self,
            showLogView: true,
            onLoadComplete: onLoadComplete,
            onJavaScriptError: onJavaScriptError,
            onCustomMessage: onCustomMessage
        )
    }
    
    /// 判断URL是否可以在WebView中展示
    var canOpenInWebView: Bool {
        let webSchemes = ["http", "https", "data", "file"]
        return scheme.map { webSchemes.contains($0.lowercased()) } ?? false
    }
}

#if DEBUG
#Preview("WebView Demo") {
    MagicWebViewDemo()
        .frame(height: 800)
}
#endif
