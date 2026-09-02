import CisumUI
import ProviderPluginManaging
import SwiftUI

/// 插件管理页右侧详情面板（复刻 Lumi `PluginPluginManager.PluginSettingsDetailView`）。
///
/// 展示选中插件的元信息（图标 / 名称 / id / 描述 / 策略）与启停开关；
/// 最近一次启停失败的错误信息也会展示。
struct PluginSettingsDetailView: View {
    let manager: any PluginManaging
    let plugin: any SuperPlugin

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            Divider()

            descriptionSection

            policySection

            Divider()

            PluginEnableControl(manager: manager, plugin: plugin)

            if let errorDescription = manager.lastErrorDescription {
                Label(errorDescription, systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// 图标 + 名称 + id。
    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: type(of: plugin).metadata.iconName)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 36, height: 36)
                .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(type(of: plugin).metadata.displayName)
                    .font(.title3.weight(.semibold))
                Text(plugin.id)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
        }
    }

    /// 插件描述。
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("描述")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(type(of: plugin).metadata.description.isEmpty ? "无描述" : type(of: plugin).metadata.description)
                .font(.body)
                .foregroundStyle(.primary)
                .textSelection(.enabled)
        }
    }

    /// 启用策略信息。
    private var policySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("策略")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                policyBadge
                Text(type(of: plugin).metadata.policy.defaultEnabled ? "默认启用" : "默认禁用")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var policyBadge: some View {
        switch type(of: plugin).metadata.policy {
        case .alwaysOn:
            badge("始终启用", systemImage: "lock.fill")
        case .optOut:
            badge("默认启用 · 可关闭", systemImage: "switch.2")
        case .optIn:
            badge("默认禁用 · 可开启", systemImage: "switch.2")
        case .disabled:
            badge("已停用", systemImage: "slash.circle")
        }
    }

    private func badge(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.quaternary.opacity(0.6), in: Capsule())
    }
}
