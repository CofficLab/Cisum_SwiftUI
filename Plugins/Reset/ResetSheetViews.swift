import SwiftUI
import MagicCore

struct ResetConfirmContent: View {
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.quaternary)
                        .frame(width: 60, height: 60)
                    Image(systemName: .iconReset)
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.tint)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("确认重置？")
                        .font(.headline)
                    Text("重置后：\n- 数据仓库将恢复为默认位置\n- 所有用户偏好将被重置\n此操作不可撤销。是否继续？")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }
            HStack {
                Spacer()
                Button("取消") { onCancel() }
                Button("继续重置") { onConfirm() }
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct ResetProgressContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.quaternary)
                        .frame(width: 60, height: 60)
                    Image(systemName: .iconReset)
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.tint)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("正在重置…")
                        .font(.headline)
                    Text("请稍候，数据仓库将恢复为默认，用户偏好将被重置。")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }
            .padding(.bottom, 8)
            ProgressView()
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


