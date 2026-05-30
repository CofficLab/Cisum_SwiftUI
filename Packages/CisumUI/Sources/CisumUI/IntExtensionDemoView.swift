import SwiftUI
import MagicKit

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
