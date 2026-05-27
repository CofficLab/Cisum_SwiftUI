#if os(iOS)
    import SwiftUI
    @preconcurrency import WebKit

    public class WebViewCache: ObservableObject {
        // 存储网页视图及其协调器的元组
        private var storage: [URL: (WKWebView, WebViewCoordinator)] = [:]
        private let lock = NSLock()

        public init() {}

        internal func get(for url: URL) -> (WKWebView, WebViewCoordinator)? {
            lock.lock()
            defer { lock.unlock() }
            return storage[url]
        }

        internal func set(_ value: (WKWebView, WebViewCoordinator), for url: URL) {
            lock.lock()
            defer { lock.unlock() }
            storage[url] = value
        }
        
        public func clear() {
            lock.lock()
            defer { lock.unlock() }
            storage.removeAll()
        }
    }

    public struct WebViewCacheKey: EnvironmentKey {
        public static let defaultValue: WebViewCache? = nil
    }

    extension EnvironmentValues {
        public var webViewCache: WebViewCache? {
            get { self[WebViewCacheKey.self] }
            set { self[WebViewCacheKey.self] = newValue }
        }
    }

    internal struct WebViewWrapper: UIViewRepresentable {
        let url: URL
        let logger: MagicLogger
        let onLoadComplete: ((Error?) -> Void)?
        let onJavaScriptError: ((String, Int, String) -> Void)?
        let onCustomMessage: ((Any) -> Void)?
        let isVerboseMode: Bool

        @Environment(WebViewStore.self) private var webViewStore
        @Environment(\.webViewCache) private var webViewCache

        func makeCoordinator() -> WebViewCoordinator {
            if let cache = webViewCache, let (_, coordinator) = cache.get(for: url) {
                // 协调器已缓存。更新其属性。
                if isVerboseMode { logger.debug("Reusing cached Coordinator for \(url.absoluteString)") }
                coordinator.url = url
                coordinator.logger = logger
                coordinator.onLoadComplete = onLoadComplete
                coordinator.onJavaScriptError = onJavaScriptError
                coordinator.onCustomMessage = onCustomMessage
                coordinator.isVerboseMode = isVerboseMode
                return coordinator
            }

            // 没有缓存的协调器，创建一个新的。
            if isVerboseMode { logger.debug("Creating new Coordinator for \(url.absoluteString)") }
            return WebViewCoordinator(
                url: url,
                logger: logger,
                onLoadComplete: onLoadComplete,
                onJavaScriptError: onJavaScriptError,
                onCustomMessage: onCustomMessage,
                isVerboseMode: isVerboseMode
            )
        }

        func makeUIView(context: Context) -> WKWebView {
            if let cache = webViewCache, let (webView, _) = cache.get(for: url) {
                // 网页视图已缓存。其代理是我们刚配置好的协调器，无需额外操作，这对动画更安全。
                if isVerboseMode { logger.debug("Reusing cached WebView for \(url.absoluteString)") }
                webViewStore.webView = webView
                return webView
            }

            // 没有缓存的网页视图，创建一个新的。
            if isVerboseMode { logger.info("Creating new WebView for: \(url.absoluteString)") }
            let configuration = configureWebView(coordinator: context.coordinator, logger: logger)
            let webView = WKWebView(frame: .zero, configuration: configuration)
            webView.navigationDelegate = context.coordinator

            #if DEBUG
                if #available(iOS 16.4, *) {
                    webView.isInspectable = true
                }
            #endif

            if isVerboseMode {
                logger.debug("WebView 配置完成，准备加载内容")
            }
            webView.load(URLRequest(url: url))

            webViewStore.webView = webView
            // 将新的网页视图和协调器元组存入缓存
            webViewCache?.set((webView, context.coordinator), for: url)
            return webView
        }

        func updateUIView(_ uiView: WKWebView, context: Context) {
            if isVerboseMode {
                logger.debug("WebView 更新: target=\(url.absoluteString), current=\(uiView.url?.absoluteString ?? "nil")")
            }
            // 当 SwiftUI 更新时如果 URL 发生变化，则在现有 WKWebView 上加载新地址
            if uiView.url != url {
                if isVerboseMode {
                    logger.info("WebView 跳转: \(url.absoluteString)")
                }
                uiView.load(URLRequest(url: url))
            }
        }
    }
#endif
