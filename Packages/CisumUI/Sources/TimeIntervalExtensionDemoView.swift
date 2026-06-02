import SwiftUI
import MagicKit

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
