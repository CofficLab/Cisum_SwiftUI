#if DEBUG
import SwiftUI

/// 日期格式化演示视图
struct DateFormattingDemoView: View {
    @State private var date = Date()
    @State private var pastDate = Date().addingTimeInterval(-3600) // 1小时前
    @State private var futureDate = Date().addingTimeInterval(7200) // 2小时后
    @State private var oldDate = Date().addingTimeInterval(-86400 * 10) // 10天前

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 静态属性部分
                VStack(alignment: .leading, spacing: 12) {
                    Text("静态属性")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        MagicKeyValue(key: "now", value: Date.now)
                        MagicKeyValue(key: "nowCompact", value: Date.nowCompact)
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // 实例属性部分
                VStack(alignment: .leading, spacing: 12) {
                    Text("实例属性")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        MagicKeyValue(key: "fullDateTime", value: date.fullDateTime)
                        MagicKeyValue(key: "compactDateTime", value: date.compactDateTime)
                        MagicKeyValue(key: "logTime", value: date.logTime)
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // 相对时间部分
                VStack(alignment: .leading, spacing: 12) {
                    Text("相对时间格式")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        MagicKeyValue(key: "当前时间.relativeTime", value: date.relativeTime)
                        MagicKeyValue(key: "1小时前.relativeTime", value: pastDate.relativeTime)
                        MagicKeyValue(key: "2小时后.relativeTime", value: futureDate.relativeTime)
                        MagicKeyValue(key: "10天前.smartRelativeTime", value: oldDate.smartRelativeTime)
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // 工具方法部分
                VStack(alignment: .leading, spacing: 12) {
                    Text("工具方法")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        MagicKeyValue(key: "toString(date)", value: Date.toString(date))
                        MagicKeyValue(key: "toString(nil)", value: Date.toString(nil))
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // DateComponentsFormatter 演示
                VStack(alignment: .leading, spacing: 12) {
                    Text("DateComponentsFormatter")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        MagicKeyValue(
                            key: "abbreviated (9015秒)",
                            value: DateComponentsFormatter.abbreviated.string(from: 9015) ?? "N/A"
                        )
                        MagicKeyValue(
                            key: "positional (270秒)",
                            value: DateComponentsFormatter.positional.string(from: 270) ?? "N/A"
                        )
                        if #available(iOS 13.0, macOS 10.15, *) {
                            MagicKeyValue(
                                key: "relative (1小时前)",
                                value: RelativeDateTimeFormatter.standard.localizedString(for: pastDate, relativeTo: date)
                            )
                        }
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
        }
        .navigationTitle("Date 扩展演示")
    }
}

#if DEBUG
#Preview("Date 格式化演示") {
    NavigationStack {
        DateFormattingDemoView()
    }
}
#endif

#endif
