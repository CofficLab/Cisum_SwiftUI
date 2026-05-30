import SwiftUI

/// 标题对齐方式枚举
public enum MagicSettingSectionTitleAlignment {
    case leading
    case center
    case trailing
}

/// A container view that groups related settings together
public struct MagicSettingSection<Content: View>: View {
    let title: String?
    let titleAlignment: MagicSettingSectionTitleAlignment
    let content: Content

    public init(
        title: String? = nil,
        titleAlignment: MagicSettingSectionTitleAlignment = .leading,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.titleAlignment = titleAlignment
        self.content = content()
    }

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                if let title {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: titleAlignment == .leading ? .leading : titleAlignment == .center ? .center : .trailing)
                        .padding(.leading, titleAlignment == .leading ? 4 : 0)
                        .padding(.trailing, titleAlignment == .trailing ? 4 : 0)
                }

                content
                    .padding(.leading, 4)
            }
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    VStack(spacing: 20) {
        // 默认左对齐标题（不设置对齐方式）
        MagicSettingSection(title: "Default") {
            VStack(spacing: 8) {
                Text("Setting Item 1")
                Text("Setting Item 2")
                Text("Setting Item 3")
            }
        }
        
        // 左对齐标题（明确设置）
        MagicSettingSection(title: "General", titleAlignment: .leading) {
            VStack(spacing: 8) {
                Text("Setting Item 1")
                Text("Setting Item 2")
                Text("Setting Item 3")
            }
        }
        
        // 居中对齐标题
        MagicSettingSection(title: "Advanced", titleAlignment: .center) {
            VStack(spacing: 8) {
                Text("Setting Item 1")
                Text("Setting Item 2")
                Text("Setting Item 3")
            }
        }
        
        // 右对齐标题
        MagicSettingSection(title: "Custom", titleAlignment: .trailing) {
            VStack(spacing: 8) {
                Text("Setting Item 1")
                Text("Setting Item 2")
                Text("Setting Item 3")
            }
        }
        
        // 无标题
        MagicSettingSection {
            VStack(spacing: 8) {
                Text("Setting Item 1")
                Text("Setting Item 2")
                Text("Setting Item 3")
            }
        }
    }
    
    .frame(width: 500)
    .padding()
}
#endif
