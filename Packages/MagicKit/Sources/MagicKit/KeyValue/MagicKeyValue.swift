import SwiftUI

/// 键值对行组件，支持复制功能和自定义图标
public struct MagicKeyValue<Icon: View>: View {
    /// 键名
    private let key: String
    /// 值
    private let value: String
    /// 自定义图标
    private let icon: Icon?
    /// 是否已复制状态
    @State private var isCopied = false

    /// 创建键值对行组件（带复制功能）
    /// - Parameters:
    ///   - key: 键名
    ///   - value: 值
    public init(key: String, value: String) where Icon == Never {
        self.key = key
        self.value = value
        self.icon = nil
    }

    /// 创建键值对行组件（带自定义图标）
    /// - Parameters:
    ///   - key: 键名
    ///   - value: 值
    ///   - icon: 自定义图标视图
    public init(key: String, value: String, @ViewBuilder icon: () -> Icon) {
        self.key = key
        self.value = value
        self.icon = icon()
    }

    /// 视图主体
    /// 显示键值对的水平布局，支持复制功能或自定义图标
    public var body: some View {
        HStack {
            Text(key)
            Spacer()
            Text(value)
                .monospaced()

            if let icon = icon {
                icon
                    .foregroundStyle(.secondary)
            } else {
                Button {
                    value.copy()
                    withAnimation {
                        isCopied = true
                    }

                    // 2秒后重置状态
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isCopied = false
                        }
                    }
                } label: {
                    Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                        .foregroundStyle(isCopied ? .green : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
