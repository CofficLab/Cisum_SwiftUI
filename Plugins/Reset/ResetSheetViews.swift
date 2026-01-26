import MagicKit
import SwiftUI

struct ResetConfirmContent: View {
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.quaternary)
                        .frame(width: 90, height: 90)
                    Image(systemName: .iconReset)
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundStyle(.tint)
                }
                VStack(alignment: .center, spacing: 6) {
                    Text("确认重置？")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("重置后：\n- 数据仓库将恢复为默认位置\n- 所有用户偏好将被重置\n此操作不可撤销。是否继续？")
                        .foregroundStyle(.secondary)
                        .font(.body)
                }
            }
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark")
                    Text("取消")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .inCard()
                .inButtonWithAction(onCancel)

                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("继续重置")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .inCard()
                .inButtonWithAction(onConfirm)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct ResetProgressContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.quaternary)
                        .frame(width: 60, height: 60)
                    Image(systemName: .iconReset)
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.tint)
                }

                Text("正在重置…")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.bottom, 8)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(0.15))
        }
    }
}

// MARK: - Preview

#Preview("ResetConfirmContent") {
    ResetConfirmContent(onCancel: {}, onConfirm: {})
        .padding()
        .frame(width: 400)
        .inRootView()
}

#Preview("ResetProgressContent", traits: .sizeThatFitsLayout) {
    ResetProgressContent()
        .padding()
}

#Preview("ResetConfirmContent - Dark") {
    ResetConfirmContent(onCancel: {}, onConfirm: {})
        .padding()
        .frame(width: 400)
        .inRootView()
        .preferredColorScheme(.dark)
}

#Preview("ResetProgressContent - Dark", traits: .sizeThatFitsLayout) {
    ResetProgressContent()
        .padding()
        .preferredColorScheme(.dark)
}

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 600)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
