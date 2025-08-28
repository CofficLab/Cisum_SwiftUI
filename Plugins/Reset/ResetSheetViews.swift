import MagicCore
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
                MagicButton.simple(
                    icon: .systemName("xmark"),
                    title: "取消",
                    style: .secondary,
                    size: .auto,
                    shape: .roundedRectangle
                ) {
                    onCancel()
                }
                .magicShapeVisibility(.always)
                .frame(height: 44)

                MagicButton.simple(
                    icon: .systemName("checkmark.circle.fill"),
                    title: "继续重置",
                    style: .primary,
                    size: .auto,
                    shape: .roundedRectangle
                ) {
                    onConfirm()
                }
                .magicShapeVisibility(.always)
                .frame(height: 44)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
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

#Preview("ResetConfirmContent") {
    RootView {
        ResetConfirmContent(onCancel: {}, onConfirm: {})
            .padding()
            .frame(width: 400)
    }
}

#Preview("ResetProgressContent", traits: .sizeThatFitsLayout) {
    ResetProgressContent()
        .padding()
}

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
