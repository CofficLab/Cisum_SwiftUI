import SwiftUI

/// 键值对行包装器，支持链式调用
public struct MagicKeyValueRow: View {
    /// 键文本视图
    private let keyText: Text
    /// 值字符串
    private let value: String
    /// 可选的自定义图标
    private var icon: AnyView?

    /// 初始化方法
    /// - Parameters:
    ///   - keyText: 键文本视图
    ///   - value: 值字符串
    ///   - icon: 可选的自定义图标
    internal init(keyText: Text, value: String, icon: AnyView? = nil) {
        self.keyText = keyText
        self.value = value
        self.icon = icon
    }

    /// 视图主体
    /// 实现键值对的水平布局，支持复制功能或自定义图标
    public var body: some View {
        HStack {
            keyText
            Spacer()
            Text(value)
                .monospaced()

            if let icon = icon {
                icon
                    .foregroundStyle(.secondary)
            } else {
                CopyButton(value: value)
            }
        }
    }

    /// 添加自定义图标
    /// - Parameter icon: 图标视图
    /// - Returns: 新的键值对行实例
    public func withIcon(_ icon: some View) -> MagicKeyValueRow {
        MagicKeyValueRow(keyText: keyText, value: value, icon: AnyView(icon))
    }
}

/// 复制按钮组件
private struct CopyButton: View {
    /// 要复制的值
    let value: String
    /// 是否已复制状态
    @State private var isCopied = false

    var body: some View {
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
