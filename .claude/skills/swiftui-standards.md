---
name: swiftui-standards
description: SwiftUI 开发标准规范，包括代码组织、MARK 分组、日志记录、预览代码和事件监听的统一规范。
---

# SwiftUI 开发标准规范

本技能确保所有 SwiftUI 代码遵循项目的统一开发规范。

## 何时使用

- 编写新的 SwiftUI 视图
- 重构现有 Swift 代码
- 实现事件监听
- 添加日志记录
- 组织代码结构

## 核心规范

### 1. 代码组织原则

**文件组织：**
- 每个 struct/class 应该放在独立的文件中
- 文件名应与类型名称保持一致
- 相关组件应组织在同一目录下
- 代码迁移后不添加"已迁移"注释

**目录结构：**
```
Core/
├── Events/          # 所有事件相关代码
│   ├── AppEvents.swift
│   └── SettingEvents.swift
├── Bootstrap/
├── Contract/
└── Models/
```

### 2. MARK 分组规范

所有 SwiftUI 视图文件必须按以下顺序使用 MARK 分组：

```swift
// MARK: - View          - SwiftUI View 主体实现
// MARK: - Action        - 用户交互触发的行为
// MARK: - Setter        - 状态/属性的集中更新方法
// MARK: - Event Handler - 事件处理函数
// MARK: - Preview       - 多尺寸预览
```

**示例模板：**
```swift
import SwiftUI

struct MyView: View {
    @State private var isLoading = false
    @State private var items: [String] = []

    var body: some View {
        List(items, id: \.self) { Text($0) }
            .onAppear(perform: handleOnAppear)
    }
}

// MARK: - View
extension MyView {
    private var filteredItems: [String] {
        items.filter { !$0.isEmpty }
    }
}

// MARK: - Action
extension MyView {
    func refresh() {
        // 刷新逻辑
    }
}

// MARK: - Setter
extension MyView {
    @MainActor
    func setItems(_ newValue: [String]) {
        items = newValue
        isLoading = false
    }
}

// MARK: - Event Handler
extension MyView {
    func handleOnAppear() {
        isLoading = true
    }
}

// MARK: - Preview
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
```

### 3. SuperLog 日志协议

**所有需要日志的类型必须实现 SuperLog 协议：**

```swift
struct MyView: View, SuperLog {
    nonisolated static let emoji = "🎯"
    nonisolated static let verbose = false

    func someFunction() {
        if Self.verbose {
            os_log("\(self.t)Some operation started")
        }
        os_log("\(self.t)Operation completed")
    }
}
```

**协议要求：**
- 实现 `nonisolated static let emoji` - 独特的 emoji 标识
- 实现 `nonisolated static let verbose` - 详细日志控制
- 使用 `self.t` 作为日志前缀（自动包含 emoji 和类型名）

**日志级别：**
```swift
// 总是输出
os_log("\(self.t)Important operation completed")

// 仅开发时输出
if Self.verbose {
    os_log("\(self.t)Detailed debug information")
}
```

### 4. 事件监听规范

**事件抛出时，必须为 View 扩展添加 onXxx 方法：**

```swift
// 在 Core/Events/ 目录中实现
extension View {
    func onCustomEvent(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .customEvent)) { _ in
            action()
        }
    }
}

// 使用时必须使用 perform: 语法
.onCustomEvent(perform: handleEvent)

func handleEvent() {
    // 事件处理逻辑
}
```

**事件文件组织：**
- 所有事件扩展放在 `Core/Events/` 目录
- `AppEvents.swift` - 应用生命周期事件
- `SettingEvents.swift` - 设置相关事件

### 5. 预览代码规范

**每个 Swift 文件底部必须添加多尺寸预览：**

```swift
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
```

## Emoji 选择指南

### UI 相关
- `🌿` - View 组件
- `📱` - 移动端
- `🖥️` - 桌面端
- `🎛️` - 控制面板
- `📋` - 表单组件

### 数据相关
- `🏠` - 数据提供者
- `💾` - 数据存储
- `📊` - 数据分析
- `🔄` - 数据同步

### 业务功能
- `🔧` - 工具类
- `📁` - 文件管理
- `🌳` - 项目管理
- `📝` - 文本编辑
- `🔍` - 搜索功能

### 系统相关
- `🍎` - macOS
- `⚙️` - 系统配置
- `🔗` - 网络连接
- `🔔` - 通知系统

## 最佳实践

### 代码组织
- ✅ 使用 extension 隔离不同分组
- ✅ 保持 MARK 分组顺序统一
- ✅ 语义化命名：`onXxx` / `handleXxx`
- ✅ 状态更新集中在 Setter 分组

### 日志记录
- ✅ 通过 emoji 快速过滤日志：`log stream | grep "🌿"`
- ✅ 使用 verbose 控制调试级别
- ✅ 避免记录敏感信息
- ✅ 使用 `nonisolated static` 优化性能

### 事件处理
- ✅ 使用 `perform:` 语法一行完成
- ✅ 事件扩展放在 `Core/Events/` 目录
- ✅ 确保方法名唯一
- ✅ 注意线程安全和内存管理

### 预览代码
- ✅ 提供多种尺寸预览
- ✅ 使用条件编译适配平台
- ✅ 使用 `inRootView()` 包装

## 注意事项

1. **文件迁移**：迁移代码后不添加"已迁移"注释
2. **命名冲突**：确保 `onXxx` 方法名在项目中唯一
3. **线程安全**：UI 更新操作使用 `@MainActor`
4. **内存管理**：避免事件监听中的循环引用
5. **日志过滤**：利用 emoji 快速定位问题类型

遵循此规范可以显著提升代码的可读性、可维护性和开发体验。
