import MagicKit
import SwiftUI

// MARK: - Sheet Container

/// Sheet 容器
///
/// 用于包装 Sheet 视图内容，提供统一的布局和交互样式
/// 在 macOS 平台自动显示关闭按钮，iOS 平台不显示
///
/// ## 使用示例
/// ```swift
/// SheetContainer {
///     VStack {
///         Text("标题")
///         Text("内容")
///     }
/// }
/// ```
struct SheetContainer<Content: View>: View {
    @Environment(\.dismiss) private var dismiss

    /// 内容视图
    @ViewBuilder var content: Content

    /// VStack 的间距
    private var spacing: CGFloat { 20 }

    var body: some View {
        VStack(spacing: spacing) {
            // 关闭按钮区域（仅 macOS 显示）
            if Config.isDesktop {
                HStack {
                    Spacer()
                    closeButton
                }
                .padding(.top, 8)
            }

            // 用户内容
            content
        }
        .padding()
        .background(Config.rootBackground)
        .infinite()
    }

    // MARK: - 子视图组件

    /// 关闭按钮 - 现代化圆形设计
    private var closeButton: some View {
        @State var hovered = false

        return Button(action: { dismiss() }) {
            Image.close
                .font(.system(size: 12, weight: .medium))
                .frame(width: 32, height: 32)
                .foregroundStyle(.secondary)
                .background(.ultraThinMaterial, in: Circle())
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        #if os(macOS)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    hovered = hovering
                }
            }
            .scaleEffect(hovered ? 1.1 : 1.0)
        #endif
        #if os(iOS)
        .scaleEffect(hovered ? 0.95 : 1.0)
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.1)) {
                hovered = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation { hovered = false }
            }
        }
        #endif
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("SheetContainer - macOS") {
        SheetContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("标题")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("这是内容区域，可以放置任意视图")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 400, height: 300)
    }
#endif

#if os(iOS)
    #Preview("SheetContainer - iPhone") {
        SheetContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("标题")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("这是内容区域，可以放置任意视图")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .inCard()
    }
#endif
