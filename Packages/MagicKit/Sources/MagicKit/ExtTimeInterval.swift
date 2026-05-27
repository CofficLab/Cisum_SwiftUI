import Foundation
import SwiftUI

/// TimeInterval 类型的扩展，提供时间格式化功能
public extension TimeInterval {
    /// 将时间间隔转换为播放器显示格式
    ///
    /// 根据时间长度自动选择显示格式：
    /// - 小于1小时：显示为 "mm:ss" 格式
    /// - 大于等于1小时：显示为 "hh:mm:ss" 格式
    ///
    /// ```swift
    /// let duration: TimeInterval = 3665 // 1小时1分5秒
    /// print(duration.displayFormat) // "1:01:05"
    ///
    /// let shortDuration: TimeInterval = 125 // 2分5秒
    /// print(shortDuration.displayFormat) // "2:05"
    /// ```
    /// - Returns: 格式化后的时间字符串，格式为 "mm:ss" 或 "hh:mm:ss"
    var displayFormat: String {
        TimeFormatter.format(self)
    }
}

/// 时间格式化工具结构体
public struct TimeFormatter {
    /// 将时间间隔转换为显示格式
    ///
    /// 根据时间长度自动选择显示格式：
    /// - 小于1小时：显示为 "mm:ss" 格式
    /// - 大于等于1小时：显示为 "hh:mm:ss" 格式
    ///
    /// ```swift
    /// let duration: TimeInterval = 3665
    /// print(TimeFormatter.format(duration)) // "1:01:05"
    /// ```
    /// - Parameter timeInterval: 时间间隔（秒）
    /// - Returns: 格式化后的时间字符串，格式为 "mm:ss" 或 "hh:mm:ss"
    public static func format(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval / 3600)
        let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

/// TimeInterval 扩展功能演示视图
struct TimeIntervalExtensionDemoView: View {
    var body: some View {
        TabView {
            // 时间格式化演示
            VStack(spacing: 20) {
                // 基础格式化
                VStack(alignment: .leading, spacing: 12) {
                    Text("基础格式化")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        MagicKeyValue(key: "30.displayFormat", value: TimeInterval(30).displayFormat) {
                            Image(systemName: .iconTimer)
                        }
                        MagicKeyValue(key: "65.displayFormat", value: TimeInterval(65).displayFormat) {
                            Image(systemName: .iconTimer)
                        }
                        MagicKeyValue(key: "3665.displayFormat", value: TimeInterval(3665).displayFormat) {
                            Image(systemName: .iconTimer)
                        }
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // 特殊情况
                VStack(alignment: .leading, spacing: 12) {
                    Text("特殊情况")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        MagicKeyValue(key: "0.displayFormat", value: TimeInterval(0).displayFormat) {
                            Image(systemName: .iconTimer)
                        }
                        MagicKeyValue(key: "3600.displayFormat", value: TimeInterval(3600).displayFormat) {
                            Image(systemName: .iconTimer)
                        }
                        MagicKeyValue(key: "7323.displayFormat", value: TimeInterval(7323).displayFormat) {
                            Image(systemName: .iconTimer)
                        }
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()

            .tabItem {
                Image(systemName: .iconTimer)
                Text("格式化")
            }
        }
    }
}

#if DEBUG
#Preview("时间格式化演示") {
    NavigationStack {
        TimeIntervalExtensionDemoView()
    }
}
#endif
