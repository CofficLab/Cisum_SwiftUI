#if DEBUG
import SwiftUI

/// WebView功能演示视图
public struct MagicWebViewDemo: View {
    @State private var receivedMessages: [String] = []
    @State private var showLog = true  // 添加状态变量控制日志显示

    public init() {}

    public var body: some View {
        TabView {
            // 基本功能演示
            VStack {
                let webView = URL(string: "https://www.apple.com")!.makeWebView { error in
                    if let error = error {
                        MagicLogger.error("Apple.com加载失败: \(error.localizedDescription)")
                    } else {
                        MagicLogger.info("Apple.com加载完成")
                    }
                }

                webView
                    .showLogView(true)
            }
            .tabItem {
                Label("在线网页", systemImage: "globe")
            }
            
            // 磁盘文件
            VStack {
                let webView = URL.sample_temp_html.makeWebView { error in
                    if let error = error {
                        MagicLogger.error("\(URL.sample_temp_txt)加载失败: \(error.localizedDescription)")
                    } else {
                        MagicLogger.info("\(URL.sample_temp_txt)加载完成")
                    }
                }

                webView
                    .showLogView(true)
            }
            .tabItem {
                Label("磁盘文件", systemImage: "globe")
            }

            // 错误处理演示
            VStack {
                let invalidWebView = URL(string: "file:///invalid")!.makeWebView { error in
                    if let error = error {
                        MagicLogger.shared.error("无效URL加载失败: \(error.localizedDescription)")
                    }
                }

                invalidWebView
            }
            .tabItem {
                Label("错误", systemImage: "exclamationmark.triangle")
            }

            // JavaScript错误演示
            VStack {
                // 包含JS错误的HTML
                let htmlWithError = """
                <html>
                <head>
                    <meta charset="utf-8">
                </head>
                <body>
                    <h1>JavaScript错误演示</h1>
                    <script>
                        // 立即执行一个错误
                        undefinedFunction();  // 这会立即触发一个错误

                        // 语法错误
                        const obj = {
                            name: "test",,  // 多余的逗号会导致语法错误
                        };
                    </script>
                </body>
                </html>
                """

                let url = URL(string: "data:text/html;base64," + Data(htmlWithError.utf8).base64EncodedString())!

                url.makeWebView(
                    onJavaScriptError: { message, line, source in
                        print("检测到 JS 错误！") // 添加调试输出
                        MagicLogger.shared.error("JavaScript错误检测到：")
                        MagicLogger.shared.error("- 消息: \(message)")
                        MagicLogger.shared.error("- 行号: \(line)")
                        MagicLogger.shared.error("- 来源: \(source)")
                    }
                )
                .showLogView(true)
            }
            .tabItem {
                Label("JS错误", systemImage: "exclamationmark.bubble")
            }

            // URL跳转演示
            TabView {
                OnlineJumpDemoView()
                    .tabItem {
                        Label("在线跳转", systemImage: "globe")
                    }

                LocalJumpDemoView()
                    .tabItem {
                        Label("本地跳转", systemImage: "externaldrive")
                    }
            }
            .tabItem {
                Label("URL跳转", systemImage: "arrow.right.circle")
            }

            // JavaScript通信演示
            VStack {
                // 包含JavaScript通信示例的HTML
                let htmlWithJSCommunication = """
                <html>
                <head>
                    <meta charset="utf-8">
                    <style>
                        body { font-family: -apple-system, sans-serif; padding: 20px; }
                        button { 
                            padding: 10px 20px;
                            margin: 5px;
                            font-size: 16px;
                            border-radius: 8px;
                            border: none;
                            background-color: #007AFF;
                            color: white;
                            cursor: pointer;
                        }
                        button:active {
                            background-color: #0051A8;
                        }
                    </style>
                </head>
                <body>
                    <h2>JavaScript 与 Swift 通信演示</h2>

                    <button onclick="sendSimpleMessage()">发送简单消息</button>
                    <button onclick="sendJsonMessage()">发送JSON消息</button>
                    <button onclick="sendComplexData()">发送复杂数据</button>

                    <script>
                        // 发送简单消息
                        function sendSimpleMessage() {
                            window.webkit.messageHandlers.customMessage.postMessage("你好，Swift！");
                        }

                        // 发送JSON消息
                        function sendJsonMessage() {
                            window.webkit.messageHandlers.customMessage.postMessage({
                                type: "json",
                                data: {
                                    message: "这是一个JSON消息",
                                    timestamp: new Date().toISOString()
                                }
                            });
                        }

                        // 发送复杂数据
                        function sendComplexData() {
                            try {
                                const complexData = {
                                    type: "complexData",
                                    data: {
                                        numbers: [1, 2, 3, 4, 5],
                                        text: "复杂数据示例",
                                        nested: {
                                            bool: true,
                                            date: new Date().toISOString()
                                        }
                                    }
                                };
                                console.log("准备发送复杂数据:", JSON.stringify(complexData));
                                window.webkit.messageHandlers.customMessage.postMessage(complexData);
                                console.log("复杂数据发送完成");
                            } catch (error) {
                                console.error("发送复杂数据时出错:", error);
                                window.webkit.messageHandlers.jsError.postMessage({
                                    message: error.message,
                                    sourceURL: "sendComplexData",
                                    lineNumber: 0
                                });
                            }
                        }

                        // 页面加载完成后自动发送一条消息
                        window.onload = function() {
                            window.webkit.messageHandlers.customMessage.postMessage({
                                type: "pageLoad",
                                data: "页面加载完成！"
                            });
                        };
                    </script>
                </body>
                </html>
                """

                let url = URL(string: "data:text/html;base64," + Data(htmlWithJSCommunication.utf8).base64EncodedString())!

                let webView = url.makeWebView { error in
                    if let error = error {
                        MagicLogger.shared.error("演示页面加载失败: \(error.localizedDescription)")
                    } else {
                        MagicLogger.shared.info("演示页面加载成功")
                    }
                } onJavaScriptError: { message, line, source in
                    MagicLogger.shared.error("JavaScript错误:")
                    MagicLogger.shared.error("- 消息: \(message)")
                    MagicLogger.shared.error("- 行号: \(line)")
                    MagicLogger.shared.error("- 来源: \(source)")
                } onCustomMessage: { message in
                    MagicLogger.shared.debug("收到消息: \(String(describing: message))")
                }

                webView
                    .showLogView(true)
            }
            .tabItem {
                Label("JS通信", systemImage: "message")
            }

            // JavaScript执行演示
            VStack {
                // 包含可执行函数的HTML
                let htmlWithFunctions = """
                <html>
                <head>
                    <meta charset="utf-8">
                    <style>
                        body { font-family: -apple-system, sans-serif; padding: 20px; }
                        .result { 
                            margin: 10px 0;
                            padding: 10px;
                            background: #f0f0f0;
                            border-radius: 8px;
                        }
                    </style>
                </head>
                <body>
                    <h2>JavaScript 函数执行演示</h2>
                    <div id="result" class="result">结果将显示在这里</div>
                    
                    <script>
                        // 示例函数1：简单计算
                        function calculate(a, b) {
                            const result = a + b;
                            document.getElementById('result').textContent = `计算结果: ${a} + ${b} = ${result}`;
                            return result;
                        }
                        
                        // 示例函数2：修改DOM
                        function updateDOM(text) {
                            document.getElementById('result').textContent = text;
                            return '更新成功';
                        }
                        
                        // 示例函数3：返回复杂数据
                        function getComplexData() {
                            return {
                                timestamp: new Date().toISOString(),
                                numbers: [1, 2, 3],
                                text: "这是一些数据"
                            };
                        }
                    </script>
                </body>
                </html>
                """

                let url = URL(string: "data:text/html;base64," + Data(htmlWithFunctions.utf8).base64EncodedString())!
                
                VStack(spacing: 10) {
                    let webView = url.makeWebView()
                        .showLogView(true)
                    
                    webView
                    
                    HStack(spacing: 10) {
                        Button("执行计算") {
                            webView.evaluateJavaScript("calculate(10, 20)")
                        }
                        
                        Button("更新DOM") {
                            webView.evaluateJavaScript("""
                                updateDOM('DOM已更新：' + new Date().toLocaleTimeString())
                            """)
                        }
                        
                        Button("获取数据") {
                            webView.evaluateJavaScript("getComplexData()")
                        }
                    }
                    .padding()
                }
            }
            .tabItem {
                Label("执行JS", systemImage: "command")
            }

            // 日志显示控制演示
            VStack {
                Toggle("显示日志", isOn: $showLog)
                    .padding()
                
                let webView = URL(string: "https://www.apple.com")!.makeWebView { error in
                    if let error = error {
                        MagicLogger.shared.error("加载失败: \(error.localizedDescription)")
                    } else {
                        MagicLogger.shared.info("加载完成")
                        // 输出一些测试日志
                        MagicLogger.shared.debug("这是一条调试日志")
                        MagicLogger.shared.info("这是一条信息日志")
                        MagicLogger.shared.warning("这是一条警告日志")
                        MagicLogger.shared.error("这是一条错误日志")
                    }
                }
                
                webView
                    .showLogView(showLog)
            }
            .tabItem {
                Label("日志控制", systemImage: "text.bubble")
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("WebView Demo") {
    MagicWebViewDemo()
        .frame(height: 800)
        .frame(width: 1000)
}
#endif

// MARK: - Subviews for URL Jump Demo

private struct OnlineJumpDemoView: View {
    @State private var webView: MagicWebView = URL(string: "https://www.apple.com")!.makeWebView().showLogView(true)

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("选择要跳转的链接（goto）")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("链接1") {
                    webView = webView.goto(URL(string: "https://www.apple.com")!)
                }
                Button("链接2") {
                    webView = webView.goto(URL(string: "https://www.example.com")!)
                }
            }
            .padding(.horizontal)

            webView
        }
    }
}

private struct LocalJumpDemoView: View {
    @State private var webView: MagicWebView = URL.sample_temp_html.makeWebView().showLogView(true)

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("选择要跳转的本地页面（goto）")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("页面1") { webView = webView.goto(URL.sample_temp_html) }
                Button("页面2") { webView = webView.goto(URL.sample_temp_html_form) }
            }
            .padding(.horizontal)

            webView
        }
    }
}

#endif
