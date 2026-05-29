#if os(macOS)
    import SwiftUI
    @preconcurrency import WebKit

    internal struct MacWebViewWrapper: NSViewRepresentable {
        let url: URL
        let logger: MagicLogger
        let onLoadComplete: ((Error?) -> Void)?
        let onJavaScriptError: ((String, Int, String) -> Void)?
        let onCustomMessage: ((Any) -> Void)?
        let isVerboseMode: Bool

        @Environment(WebViewStore.self) private var webViewStore

        func makeCoordinator() -> WebViewCoordinator {
            if isVerboseMode {
                logger.debug("创建 WebView Coordinator")
            }
            return WebViewCoordinator(
                url: url,
                logger: logger,
                onLoadComplete: onLoadComplete,
                onJavaScriptError: onJavaScriptError,
                onCustomMessage: onCustomMessage,
                isVerboseMode: isVerboseMode
            )
        }

        func makeNSView(context: Context) -> WKWebView {
            if isVerboseMode {
                logger.info("准备加载网页: \(url.absoluteString)")
            }

            let configuration = configureWebView(coordinator: context.coordinator, logger: logger)
            let webView = WKWebView(frame: .zero, configuration: configuration)
            webView.navigationDelegate = context.coordinator

            #if DEBUG
                if #available(macOS 13.3, *) {
                    webView.isInspectable = true
                }
            #endif

            if isVerboseMode {
                logger.debug("WebView 配置完成，准备加载内容")
            }
            webView.load(URLRequest(url: url))

            webViewStore.webView = webView
            return webView
        }

        func updateNSView(_ nsView: WKWebView, context: Context) {
            if isVerboseMode {
                logger.debug("WebView 更新: target=\(url.absoluteString), current=\(nsView.url?.absoluteString ?? "nil")")
            }
            // 当 SwiftUI 更新时如果 URL 发生变化，则在现有 WKWebView 上加载新地址
            if nsView.url != url {
                if isVerboseMode {
                    logger.info("WebView 跳转: \(url.absoluteString)")
                }
                nsView.load(URLRequest(url: url))
            }
        }
    }
#endif
