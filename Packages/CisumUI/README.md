# LumiUI

<div align="center">

**✨ 一个优雅的 SwiftUI 设计系统，专为 macOS 应用打造**

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-macOS%2014+-blue.svg)](https://developer.apple.com/xcode/macos/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[功能特性](#-功能特性) • [快速开始](#-快速开始) • [组件预览](#-组件预览) • [设计系统](#-设计系统) • [最佳实践](#-最佳实践)

</div>

---

## 🌟 功能特性

### 🎨 完整的设计系统
- **设计令牌（Design Tokens）**：统一管理颜色、排版、间距、圆角、阴影等设计规范
- **浅色/深色模式支持**：自动适配系统配色方案，提供一致的用户体验
- **玻璃态设计语言**：现代化的毛玻璃效果，营造神秘优雅的视觉体验
- **响应式颜色**：根据环境自动调整颜色，确保可访问性

### 🧩 丰富的组件库
提供 **30+** 开箱即用的 SwiftUI 组件：

#### 基础组件
- `AppButton` - 多样化按钮（主要、次要、幽灵、色调风格）
- `AppInputField` - 文本输入框
- `AppSearchBar` - 搜索栏
- `AppAvatar` - 用户头像
- `AppTag` - 标签组件
- `AppRoleBadge` - 角色徽章

#### 卡片组件
- `GlassCard` - 玻璃态卡片容器
- `GlassInfoCard` - 信息展示卡片
- `GlassSelectionCard` - 可选择卡片
- `AppDisclosureCard` - 可展开卡片

#### 列表组件
- `AppListRow` - 标准列表行
- `AppToggleRow` - 开关列表行
- `AppContextMenuRow` - 右键菜单列表行
- `AppIdentityRow` - 身份信息行
- `GlassKeyValueRow` - 键值对行

#### 状态组件
- `AppErrorBanner` - 错误提示横幅
- `AppLoadingOverlay` - 加载遮罩层
- `AppEmptyState` - 空状态视图
- `ErrorIconView` - 错误图标

#### 布局组件
- `AppSurface` - 表面容器
- `GlassDivider` - 分隔线
- `AppLabeledDivider` - 带标签分隔线
- `GlassSectionHeader` - 分组标题

#### 其他组件
- `AppTabBar` - 标签栏
- `AppDualSegmentBar` - 双段控制条
- `AppTooltip` - 工具提示
- `AppIconButton` - 图标按钮
- `CopyMessageButton` - 复制消息按钮
- `DropOverlayCard` - 拖放叠加层
- `AppImagePreviewGrid` - 图片预览网格
- `AppSizeLabel` - 尺寸标签

### 🎭 高级特性
- **玻璃态材质**：支持自定义透明度、模糊效果和光晕
- **灵活的主题定制**：通过设计令牌轻松定制视觉风格
- **无障碍支持**：符合 WCAG AA 标准，确保良好的可访问性
- **性能优化**：使用 SwiftUI 最佳实践，确保流畅的渲染性能

---

## 🚀 快速开始

### 系统要求
- macOS 14.0+
- Xcode 15.0+
- Swift 6.0+

### 安装

在你的 `Package.swift` 中添加 LumiUI 依赖：

```swift
dependencies: [
    .package(path: "../LumiUI")
]
```

或者在 Xcode 中：
1. 选择 **File → Add Package Dependencies...**
2. 选择 **Local Package** 并导航到 LumiUI 目录
3. 添加到你的项目目标

### 基础使用

```swift
import SwiftUI
import LumiUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 24) {
            // 使用设计令牌
            Text("Hello, LumiUI")
                .font(DesignTokens.Typography.title1)
                .foregroundColor(DesignTokens.Color.semantic.textPrimary)

            // 使用预置组件
            AppButton("点击我", systemImage: "hand.tap") {
                print("按钮被点击")
            }

            // 玻璃态卡片
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("玻璃态卡片")
                        .font(DesignTokens.Typography.headline)
                    Text("优雅的毛玻璃效果")
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Color.semantic.textSecondary)
                }
            }
        }
        .padding()
        .background(DesignTokens.Color.basePalette.deepBackground)
    }
}
```

---

## 🎨 组件预览

### 按钮 (AppButton)

```swift
// 主要按钮
AppButton("保存", systemImage: "checkmark", style: .primary) {
    // 操作
}

// 次要按钮
AppButton("取消", style: .secondary) {
    // 操作
}

// 幽灵按钮
AppButton("了解更多", style: .ghost) {
    // 操作
}

// 小尺寸按钮
AppButton("删除", systemImage: "trash", style: .tonal, size: .small) {
    // 操作
}
```

### 玻璃态卡片 (GlassCard)

```swift
GlassCard(
    cornerRadius: 16,
    showShadow: true,
    glowColor: .purple
) {
    VStack(alignment: .leading) {
        Text("卡片标题")
            .font(DesignTokens.Typography.headline)
        Text("卡片内容")
            .font(DesignTokens.Typography.body)
    }
}
```

### 列表行 (AppListRow)

```swift
AppListRow(
    icon: "person.circle",
    title: "用户名",
    subtitle: "user@example.com",
    action: {
        // 点击操作
    }
)
```

### 输入框 (AppInputField)

```swift
AppInputField(
    title: "邮箱",
    placeholder: "请输入邮箱地址",
    text: $email
)
```

### 错误横幅 (AppErrorBanner)

```swift
AppErrorBanner(
    error: "操作失败，请重试",
    dismissAction: {
        showError = false
    }
)
```

---

## 🎯 设计系统

### 颜色系统

#### 基础色调
```swift
// 深色背景（OLED 优化）
DesignTokens.Color.basePalette.deepBackground
DesignTokens.Color.basePalette.surfaceBackground
DesignTokens.Color.basePalette.elevatedSurface

// 神秘氛围色
DesignTokens.Color.basePalette.mysticIndigo
DesignTokens.Color.basePalette.mysticViolet
DesignTokens.Color.basePalette.mysticAzure
```

#### 语义化颜色
```swift
// 主色调
DesignTokens.Color.semantic.primary
DesignTokens.Color.semantic.primarySecondary

// 状态色
DesignTokens.Color.semantic.success
DesignTokens.Color.semantic.warning
DesignTokens.Color.semantic.error
DesignTokens.Color.semantic.info

// 文本色
DesignTokens.Color.semantic.textPrimary
DesignTokens.Color.semantic.textSecondary
DesignTokens.Color.semantic.textTertiary
DesignTokens.Color.semantic.textDisabled
```

#### 渐变色
```swift
// 主渐变
DesignTokens.Color.gradients.primaryGradient

// 深海渐变
DesignTokens.Color.gradients.oceanGradient

// 极光渐变
DesignTokens.Color.gradients.auroraGradient
```

### 排版系统

```swift
// 标题
DesignTokens.Typography.largeTitle
DesignTokens.Typography.title1
DesignTokens.Typography.title2
DesignTokens.Typography.title3

// 正文
DesignTokens.Typography.headline
DesignTokens.Typography.bodyEmphasized
DesignTokens.Typography.body
DesignTokens.Typography.bodyMonospaced

// 辅助文本
DesignTokens.Typography.callout
DesignTokens.Typography.subheadline
DesignTokens.Typography.footnote
DesignTokens.Typography.caption1
DesignTokens.Typography.caption2
```

### 间距系统

```swift
DesignTokens.Spacing.xxs    // 4pt
DesignTokens.Spacing.xs     // 8pt
DesignTokens.Spacing.sm     // 12pt
DesignTokens.Spacing.md     // 16pt
DesignTokens.Spacing.lg     // 24pt
DesignTokens.Spacing.xl     // 32pt
DesignTokens.Spacing.xxl    // 48pt
```

### 圆角系统

```swift
DesignTokens.Radius.xs      // 4pt
DesignTokens.Radius.sm      // 8pt
DesignTokens.Radius.md      // 12pt
DesignTokens.Radius.lg      // 16pt
DesignTokens.Radius.xl      // 24pt
DesignTokens.Radius.full    // 完全圆角
```

### 材质效果

```swift
// 玻璃态材质
DesignTokens.Material.glass

// 超细腻材质
DesignTokens.Material.ultraThinMaterial

// 粗糙材质
DesignTokens.Material.thickMaterial

// 神秘氛围材质（响应式）
@Environment(\.colorScheme) var colorScheme
DesignTokens.Material.mysticGlass(for: colorScheme)
```

### 阴影系统

```swift
// 阴影颜色
DesignTokens.Shadow.subtle
DesignTokens.Shadow.medium
DesignTokens.Shadow.strong

// 阴影半径
DesignTokens.Shadow.subtleRadius    // 8pt
DesignTokens.Shadow.mediumRadius    // 16pt
DesignTokens.Shadow.strongRadius    // 32pt

// 阴影偏移
DesignTokens.Shadow.subtleOffset    // 2pt
DesignTokens.Shadow.mediumOffset    // 4pt
DesignTokens.Shadow.strongOffset    // 8pt
```

### 动画时长

```swift
DesignTokens.Duration.fast          // 0.2s
DesignTokens.Duration.normal        // 0.3s
DesignTokens.Duration.slow          // 0.5s
```

---

## 💡 最佳实践

### 1. 使用设计令牌而非硬编码值

**❌ 不推荐：**
```swift
Text("标题")
    .font(.title)
    .foregroundColor(.white)
    .padding(16)
```

**✅ 推荐：**
```swift
Text("标题")
    .font(DesignTokens.Typography.title1)
    .foregroundColor(DesignTokens.Color.semantic.textPrimary)
    .padding(DesignTokens.Spacing.md)
```

### 2. 响应式颜色使用

```swift
struct MyView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text("自适应文本")
            .foregroundColor(
                DesignTokens.Color.adaptive.textPrimary(for: colorScheme)
            )
    }
}
```

### 3. 组件组合

```swift
// 组合多个组件创建复杂 UI
GlassCard {
    VStack(spacing: DesignTokens.Spacing.md) {
        AppListRow(
            icon: "person.circle",
            title: "用户信息",
            subtitle: "点击查看详情"
        )

        GlassDivider()

        AppListRow(
            icon: "gear",
            title: "设置",
            action: { /* ... */ }
        )
    }
}
```

### 4. 可访问性支持

```swift
AppButton("提交", systemImage: "checkmark") {
    // 操作
}
.accessibilityLabel("提交表单")
.accessibilityHint("点击提交当前表单")
```

### 5. 性能优化

```swift
// 使用 @ViewBuilder 减少视图层级
@ViewBuilder
var content: some View {
    if isActive {
        ActiveView()
    } else {
        InactiveView()
    }
}

// 使用 lazy 堆栈处理大量数据
LazyVStack(spacing: DesignTokens.Spacing.sm) {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}
```

---

## 📁 项目结构

```
LumiUI/
├── Sources/LumiUI/
│   ├── DesignSystem/           # 设计令牌
│   │   ├── DesignTokens.swift
│   │   ├── ColorTokens.swift
│   │   ├── TypographyTokens.swift
│   │   ├── SpacingTokens.swift
│   │   ├── RadiusTokens.swift
│   │   ├── ShadowTokens.swift
│   │   ├── MaterialTokens.swift
│   │   └── DurationTokens.swift
│   ├── Components/             # UI 组件
│   │   ├── AppButton.swift
│   │   ├── GlassCard.swift
│   │   ├── AppListRow.swift
│   │   └── ... (30+ 组件)
│   └── Support/                # 支持文件
│       ├── AppUI.swift
│       └── Color+Hex.swift
├── Tests/LumiUITests/          # 单元测试
└── README.md
```

---

## 🧪 测试

LumiUI 包含全面的单元测试，确保组件质量和稳定性。

```bash
# 运行测试
swift test

# 查看测试覆盖率
swift test --enable-code-coverage
```

---

## 🤝 贡献

欢迎贡献！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 代码规范
- 遵循 Swift API 设计指南
- 使用 SwiftUI 最佳实践
- 确保所有公开 API 都有文档注释
- 添加适当的单元测试

---

## 📄 许可证

LumiUI 采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 🔗 相关链接

- **SwiftUI 官方文档**: [Apple Developer](https://developer.apple.com/documentation/swiftui)
- **Swift Package Manager**: [Swift.org](https://swift.org/package-manager/)

---

<div align="center">

**Made with ❤️ by CofficLab**

</div>
