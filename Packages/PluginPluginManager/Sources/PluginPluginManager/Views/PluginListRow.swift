import CisumUI
import SwiftUI

/// 插件管理页左侧列表中的单行渲染（复刻 Lumi `PluginPluginManager.PluginListRow`）。
///
/// 左侧展示插件图标 + 启用状态点，右侧两行文字（名称 + 描述），
/// 整行可点击以切换选中项。
struct PluginListRow: View {
    /// 列表行绑定的目标插件。
    let plugin: any SuperPlugin

    /// 当前是否处于选中状态。
    let isSelected: Bool

    /// 当前是否有效启用（考虑策略 + 用户覆盖）。
    let isEnabled: Bool

    /// 点击整行触发的回调，用于通知父视图更新选中项。
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                leadingAccessory
                textContent
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            isSelected ? Color.accentColor.opacity(0.12) : .clear,
            in: RoundedRectangle(cornerRadius: 6, style: .continuous)
        )
    }

    /// 左侧图标 + 启用状态指示点。
    private var leadingAccessory: some View {
        VStack(spacing: 6) {
            Image(systemName: type(of: plugin).metadata.iconName)
                .font(.body)
                .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                .frame(width: 22, height: 22)

            Circle()
                .fill(isEnabled ? Color.green : Color.secondary.opacity(0.5))
                .frame(width: 6, height: 6)
        }
        .frame(width: 22)
    }

    /// 右侧文本：名称 + 描述（描述为空时回退到 plugin.id）。
    private var textContent: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(type(of: plugin).metadata.displayName)
                .font(.callout.weight(isSelected ? .semibold : .regular))
                .lineLimit(1)

            Text(type(of: plugin).metadata.description.isEmpty ? plugin.id : type(of: plugin).metadata.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
