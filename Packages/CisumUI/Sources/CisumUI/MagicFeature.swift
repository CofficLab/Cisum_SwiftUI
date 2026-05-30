import SwiftUI

/// MagicFeature - 产品特性展示组件
/// 
/// 用于展示产品特性的统一组件，包含图标、标题、描述等元素
/// 支持自定义样式、颜色、间距等属性
public struct MagicFeature: View {
    // MARK: - Properties
    
    private let title: String
    private let description: String
    private let iconName: String
    private let color: Color
    private let spacing: CGFloat
    private let iconSize: CGFloat
    private let titleFont: Font
    private let descriptionFont: Font
    private let alignment: HorizontalAlignment
    private let showSpacer: Bool
    
    // MARK: - Init
    
    /// 初始化MagicFeature组件
    /// - Parameters:
    ///   - title: 特性标题
    ///   - description: 特性描述
    ///   - iconName: 图标名称（SF Symbols）
    ///   - color: 图标颜色，默认为蓝色
    ///   - spacing: 元素间距，默认为32
    ///   - iconSize: 图标尺寸，默认为48
    ///   - titleFont: 标题字体，默认为32号系统字体
    ///   - descriptionFont: 描述字体，默认为30号系统字体
    ///   - alignment: 垂直对齐方式，默认为leading
    ///   - showSpacer: 是否显示右侧Spacer，默认为true
    public init(
        title: String,
        description: String,
        iconName: String,
        color: Color = .blue,
        spacing: CGFloat = 32,
        iconSize: CGFloat = 48,
        titleFont: Font = .system(size: 32),
        descriptionFont: Font = .system(size: 30),
        alignment: HorizontalAlignment = .leading,
        showSpacer: Bool = true
    ) {
        self.title = title
        self.description = description
        self.iconName = iconName
        self.color = color
        self.spacing = spacing
        self.iconSize = iconSize
        self.titleFont = titleFont
        self.descriptionFont = descriptionFont
        self.alignment = alignment
        self.showSpacer = showSpacer
    }
    
    // MARK: - Body
    
    public var body: some View {
        HStack(spacing: spacing) {
            // 图标
            Image(systemName: iconName)
                .font(.system(size: iconSize))
                .foregroundColor(color)
                .frame(width: iconSize, height: iconSize)
            
            // 内容区域
            VStack(alignment: alignment, spacing: 16) {
                Text(title)
                    .font(titleFont)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(descriptionFont)
                    .foregroundColor(.secondary)
            }
            
            // 右侧Spacer
            if showSpacer {
                Spacer()
            }
        }
    }
}

// MARK: - Convenience Initializers

public extension MagicFeature {
    /// 创建紧凑型特性展示
    /// - Parameters:
    ///   - title: 特性标题
    ///   - description: 特性描述
    ///   - iconName: 图标名称
    ///   - color: 图标颜色
    /// - Returns: 紧凑型MagicFeature
    static func compact(
        title: String,
        description: String,
        iconName: String,
        color: Color = .blue
    ) -> MagicFeature {
        MagicFeature(
            title: title,
            description: description,
            iconName: iconName,
            color: color,
            spacing: 16,
            iconSize: 32,
            titleFont: .system(size: 20),
            descriptionFont: .system(size: 16)
        )
    }
    
    /// 创建大型特性展示
    /// - Parameters:
    ///   - title: 特性标题
    ///   - description: 特性描述
    ///   - iconName: 图标名称
    ///   - color: 图标颜色
    /// - Returns: 大型MagicFeature
    static func large(
        title: String,
        description: String,
        iconName: String,
        color: Color = .blue
    ) -> MagicFeature {
        MagicFeature(
            title: title,
            description: description,
            iconName: iconName,
            color: color,
            spacing: 48,
            iconSize: 64,
            titleFont: .system(size: 40),
            descriptionFont: .system(size: 36)
        )
    }
    
    /// 创建居中型特性展示
    /// - Parameters:
    ///   - title: 特性标题
    ///   - description: 特性描述
    ///   - iconName: 图标名称
    ///   - color: 图标颜色
    /// - Returns: 居中型MagicFeature
    static func centered(
        title: String,
        description: String,
        iconName: String,
        color: Color = .blue
    ) -> MagicFeature {
        MagicFeature(
            title: title,
            description: description,
            iconName: iconName,
            color: color,
            alignment: .center,
            showSpacer: false
        )
    }
}

// MARK: - View Extension

public extension View {
    /// 将视图包装在MagicFeature中
    /// - Parameters:
    ///   - title: 特性标题
    ///   - description: 特性描述
    ///   - iconName: 图标名称
    ///   - color: 图标颜色
    /// - Returns: 包装后的MagicFeature视图
    func magicFeature(
        title: String,
        description: String,
        iconName: String,
        color: Color = .blue
    ) -> some View {
        MagicFeature(
            title: title,
            description: description,
            iconName: iconName,
            color: color
        )
    }
}

// MARK: - Preview

#if DEBUG
#Preview("MagicFeature - Default") {
    MagicFeature(
        title: "快速开发",
        description: "使用MagicKit快速构建跨平台应用",
        iconName: "bolt.fill",
        color: .blue
    )
    .padding()
    .frame(width: 500, height: 100)
    .background(Color.gray.opacity(0.1))
}

#if DEBUG
#Preview("MagicFeature - Compact") {
    MagicFeature.compact(
        title: "轻量级",
        description: "极小的包体积",
        iconName: "leaf.fill",
        color: .green
    )
    .padding()
    .frame(width: 400, height: 80)
    .background(Color.gray.opacity(0.1))
}
#endif

#if DEBUG
#Preview("MagicFeature - Large") {
    MagicFeature.large(
        title: "强大功能",
        description: "提供丰富的UI组件和工具",
        iconName: "star.fill",
        color: .orange
    )
    .padding()
    .frame(width: 600, height: 150)
    .background(Color.gray.opacity(0.1))
}
#endif

#if DEBUG
#Preview("MagicFeature - Centered") {
    MagicFeature.centered(
        title: "居中展示",
        description: "内容居中对齐",
        iconName: "target",
        color: .purple
    )
    .padding()
    .frame(width: 500, height: 100)
    .background(Color.gray.opacity(0.1))
}
#endif

#if DEBUG
#Preview("MagicFeature - Custom") {
    MagicFeature(
        title: "自定义样式",
        description: "完全可定制的组件",
        iconName: "slider.horizontal.3",
        color: .red,
        spacing: 24,
        iconSize: 40,
        titleFont: .system(size: 24, weight: .bold),
        descriptionFont: .system(size: 18, weight: .medium)
    )
    .padding()
    .frame(width: 500, height: 100)
    .background(Color.gray.opacity(0.1))
}
#endif

#if DEBUG
#Preview("MagicFeature - Multiple Features") {
    VStack(spacing: 20) {
        MagicFeature(
            title: "SwiftUI 原生",
            description: "基于SwiftUI构建，性能优异",
            iconName: "swift",
            color: .orange
        )
        
        MagicFeature(
            title: "跨平台支持",
            description: "同时支持iOS和macOS",
            iconName: "iphone.and.arrow.forward",
            color: .blue
        )
        
        MagicFeature(
            title: "易于使用",
            description: "简洁的API设计",
            iconName: "hand.thumbsup.fill",
            color: .green
        )
    }
    .padding()
    .frame(width: 500, height: 300)
    .background(Color.gray.opacity(0.1))
}
#endif
#endif
