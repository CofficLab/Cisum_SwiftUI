import Foundation
import SwiftUI

/// Int 类型的扩展，提供常用的工具方法
public extension Int {
    /// 检查是否为 HTTP 成功状态码 (200-299)
    ///
    /// 用于判断 HTTP 请求是否成功
    /// ```swift
    /// let statusCode = 200
    /// if statusCode.isHttpOkCode() {
    ///     print("请求成功")
    /// }
    /// ```
    /// - Returns: 如果状态码在 200-299 范围内则返回 true
    func isHttpOkCode() -> Bool {
        self >= 200 && self < 300
    }

    /// 将整数转换为字符串
    ///
    /// 提供一个简便的方式将整数转换为字符串
    /// ```swift
    /// let count = 42
    /// let text = count.string // "42"
    /// ```
    var string: String {
        "\(self)"
    }

    /// 检查是否为偶数
    ///
    /// ```swift
    /// let number = 4
    /// if number.isEven {
    ///     print("这是偶数")
    /// }
    /// ```
    var isEven: Bool {
        self % 2 == 0
    }

    /// 检查是否为奇数
    ///
    /// ```swift
    /// let number = 3
    /// if number.isOdd {
    ///     print("这是奇数")
    /// }
    /// ```
    var isOdd: Bool {
        !isEven
    }

    /// 将整数转换为带前导零的字符串
    /// - Parameter length: 目标字符串长度
    /// - Returns: 带前导零的字符串
    ///
    /// ```swift
    /// let number = 7
    /// print(number.padded(length: 3)) // "007"
    /// ```
    func padded(length: Int) -> String {
        String(format: "%0\(length)d", self)
    }

    /// 将整数转换为人类可读的文件大小字符串
    ///
    /// ```swift
    /// let bytes = 1024 * 1024
    /// print(bytes.fileSizeString) // "1.0 MB"
    /// ```
    var fileSizeString: String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var size = Double(self)
        var unitIndex = 0

        while size >= 1024 && unitIndex < units.count - 1 {
            size /= 1024
            unitIndex += 1
        }

        return String(format: "%.1f %@", size, units[unitIndex])
    }
}

/// Int 扩展功能演示视图
struct IntExtensionDemoView: View {
    var body: some View {
        TabView {
            // 基础功能演示
            VStack(spacing: 20) {
                // HTTP 状态码
                VStack(alignment: .leading, spacing: 12) {
                    Text("HTTP 状态码")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        MagicKeyValue(key: "200", value: "200.isHttpOkCode()") {
                            Image(systemName: 200.isHttpOkCode() ? .iconCheckmark : .iconClose)
                                .foregroundStyle(200.isHttpOkCode() ? .green : .red)
                        }
                        MagicKeyValue(key: "404", value: "404.isHttpOkCode()") {
                            Image(systemName: 404.isHttpOkCode() ? .iconCheckmark : .iconClose)
                                .foregroundStyle(404.isHttpOkCode() ? .green : .red)
                        }
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // 数字属性
                VStack(alignment: .leading, spacing: 12) {
                    Text("数字属性")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        MagicKeyValue(key: "42.isEven", value: "true") {
                            Image(systemName: 42.isEven ? .iconCheckmark : .iconClose)
                                .foregroundStyle(.green)
                        }
                        MagicKeyValue(key: "7.isOdd", value: "true") {
                            Image(systemName: 7.isOdd ? .iconCheckmark : .iconClose)
                                .foregroundStyle(.green)
                        }
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()

            .tabItem {
                Image(systemName: .iconNumberCircleFill1)
                Text("基础")
            }

            // 格式化演示
            VStack(spacing: 20) {
                // 数字格式化
                VStack(alignment: .leading, spacing: 12) {
                    Text("数字格式化")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        MagicKeyValue(key: "7.padded(3)", value: "007")
                        MagicKeyValue(key: "42.string", value: "42")
                        MagicKeyValue(key: "(1024 * 1024).fileSizeString", value: (1024 * 1024).fileSizeString)
                        MagicKeyValue(key: "(1024 * 1024 * 1024).fileSizeString", value: (1024 * 1024 * 1024).fileSizeString)
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()

            .tabItem {
                Image(systemName: .iconNumberCircleFill2)
                Text("格式化")
            }
        }
    }
}

#if DEBUG
#Preview("Int 扩展演示") {
    NavigationStack {
        IntExtensionDemoView()
    }
}
#endif
