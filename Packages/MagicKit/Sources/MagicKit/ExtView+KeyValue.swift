import SwiftUI

extension Text {
    /// 为文本添加对应的值，创建键值对行
    /// - Parameter value: 对应的值
    /// - Returns: 键值对行视图
    public func withMagicValue(_ value: String) -> MagicKeyValueRow {
        MagicKeyValueRow(keyText: self, value: value, icon: nil)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("KeyValue Extensions - Basic") {
    VStack(spacing: 16) {
        Text("姓名")
            .withMagicValue("John Doe")

        Text("邮箱")
            .withMagicValue("john@example.com")

        Text("电话")
            .withMagicValue("+1 234 567 8900")
    }
    .padding()
}

#if DEBUG
#Preview("KeyValue Extensions - With Icons") {
    VStack(spacing: 16) {
        Text("姓名")
            .withMagicValue("John Doe")
            .withIcon(Image(systemName: "person.fill"))

        Text("邮箱")
            .withMagicValue("john@example.com")
            .withIcon(Image(systemName: "envelope.fill"))

        Text("电话")
            .withMagicValue("+1 234 567 8900")
            .withIcon(Image(systemName: "phone.fill"))
    }
    .padding()
}
#endif

#if DEBUG
#Preview("KeyValue Extensions - Complex") {
    VStack(spacing: 20) {
        // 用户信息组
        VStack(alignment: .leading, spacing: 12) {
            Text("用户信息")
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("用户名")
                    .withMagicValue("admin")

                Text("邮箱")
                    .withMagicValue("admin@example.com")
                    .withIcon(Image(systemName: "envelope"))

                Text("角色")
                    .withMagicValue("管理员")
                    .withIcon(Image(systemName: "person.badge.shield"))
            }
            .padding()
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }

        // 系统信息组
        VStack(alignment: .leading, spacing: 12) {
            Text("系统信息")
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("版本")
                    .withMagicValue("1.0.0")

                Text("构建号")
                    .withMagicValue("20240315001")

                Text("Token")
                    .withMagicValue("abc123xyz789")
            }
            .padding()
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    .padding()
}
#endif
#endif
