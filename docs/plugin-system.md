# Cisum 插件系统设计与开发指南

面向希望扩展 Cisum 的开发者，说明插件体系的架构、生命周期与开发步骤，帮助快速编写并上线新的插件。

## 核心设计

- **协议分层**  
  - `MagicSuperPlugin`（`MagicFramework/MagicSuperPlugin.swift`）：最小协议，定义插件元信息与根视图包装能力，提供默认实现。
  - `SuperPlugin`（`Core/Bootstrap/SuperPlugin.swift`）：应用层扩展，增加各类可选 UI 扩展点（启动页、状态视图、工具栏按钮、弹窗、存储位置等）。
- **注册中心**  
  - `MagicPluginRegistry<Plugin>`（`MagicFramework/MagicPluginRegistry.swift`）：基于 `actor` 的线程安全注册表，按 `order` 排序构建插件实例。
  - `PluginRegistry`（`Core/Providers/PluginRegistry.swift`）：对应用层的类型别名与便捷封装，提供 `shared` 单例与同步注册包装。
- **自动发现**  
  - `magicAutoRegisterPlugins()` 使用 Objective‑C Runtime 扫描所有符合 `MagicPluginRegistrant` 的类并调用其 `register()`。
  - 应用层入口 `autoRegisterPlugins()`（`Core/Providers/PluginRegistry.swift`）直接转发。
- **运行时管理**  
  - `PluginProvider`（`Core/Providers/PluginProvider.swift`）：在主线程管理插件生命周期，拉起自动发现、持久化当前分组插件、收集各类视图扩展点并以链式方式包裹根视图。
  - `PluginRepo`（`Core/Repo/PluginRepo.swift`）：持久化当前激活的插件 ID（UserDefaults + iCloud KV）。
  - `RootBox`（`Core/Bootstrap/RootBox.swift`）：应用级依赖汇聚，初始化时构造 `PluginProvider(autoDiscover: true, repo: PluginRepo())`。

## 生命周期与数据流

1. **编译期实现**：插件以 `actor` 形式实现 `SuperPlugin` 并符合 `PluginRegistrant`（继承自 `MagicPluginRegistrant`），在 `register()` 中登记工厂。
2. **启动自动发现**：`RootBox` 构造 `PluginProvider(autoDiscover: true)` → `PluginProvider` 内调用 `autoRegisterPlugins()` → 触发 runtime 扫描。
3. **注册入表**：每个 `register()` 将插件工厂通过 `PluginRegistry.shared.register(id:order:factory:)` 写入注册表。`order` 越小越先构建，也决定根视图包裹顺序。
4. **实例构建**：`PluginProvider` 异步调用 `PluginRegistry.shared.buildAll()`，按 `order` 排序创建实例，写入 `plugins`。
5. **当前分组恢复**：使用 `PluginRepo` 读取上次选择的插件 ID，若不存在则选第一个 `isGroup == true` 的插件并持久化。
6. **运行期调度**：UI 渲染与用户交互时，`PluginProvider` 聚合插件暴露的视图：`wrapWithCurrentRoot` 链式包裹根视图，`getStatusViews`、`getToolBarButtons`、`getSheetViews` 等按需收集。

## 插件能做什么（扩展点）

所有方法均在 `SuperPlugin` 协议中声明，默认空实现，按需覆盖：

- **根视图包裹**：`addRootView` / `wrapRoot`，像中间件一样按注册顺序包裹内容视图（A(B(C(content))))。
- **分组标记**：`isGroup` 表示是否可作为主工作区切换目标。
- **启动体验**：`addLaunchView` 返回启动阶段展示的视图（如欢迎页）。
- **状态/工具栏**：`addStatusView` 汇入状态区域；`addToolBarButtons` 返回一组按钮 `(id, view)`。
- **弹窗与面板**：`addSheetView(storage:)`、`addSettingView()`、`addDBView(reason:)`。
- **媒体与资源**：`addPosterView()`、`getDisk()`（提供插件独立存储路径）。

## 现有插件示例

- `Plugins/Audio/AudioPlugin.swift`：分组型插件，提供根视图包裹、数据库视图、设置视图、封面图及存储路径。
- `Plugins/Welcome/WelcomePlugin.swift`：非分组欢迎页，通过 `addLaunchView` 在未配置存储时引导用户。
- `Plugins/CopyPlugin/CopyPlugin.swift`（macOS）：非分组插件，追加状态视图与根视图包裹。

## 开发新插件的步骤

1. **创建插件类型**  
   - 使用 `actor`，遵循 `SuperPlugin` 与 `PluginRegistrant`。  
   - 填充元信息：`id`（可用默认 `label`）、`title/label`、`description`、`iconName`、`hasPoster`、`isGroup`。
2. **实现所需扩展点**  
   - UI 相关方法标注 `@MainActor`。  
   - 仅覆盖需要的接口，未实现的保持默认空实现。
3. **注册到系统**  
   - 在同文件通过 `extension` 添加 `@objc static func register()`。  
   - 选择合适的 `order`：数值小的优先构建且更靠近根视图外层。  
   - 通过便捷方法 `PluginRegistry.registerSync(order:) { Self() }` 或显式 `PluginRegistry.shared.register(...)`。
4. **验证加载**  
   - 启动应用，确认 `PluginProvider.plugins` 中出现新插件；如是分组插件，检查当前分组持久化是否工作。

### 最小模板

```swift
import SwiftUI
import MagicCore

actor MyPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    let title = "示例插件"
    let description = "做一件小而美的事"
    let iconName = "sparkles"
    let isGroup = false

    @MainActor
    func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(MyRootWrapper { content() })
    }

    @MainActor
    func addToolBarButtons() -> [(id: String, view: AnyView)] {
        [(id: "my.action", view: AnyView(MyToolbarButton()))]
    }
}

// MARK: - PluginRegistrant
extension MyPlugin {
    @objc static func register() {
        PluginRegistry.registerSync(order: 10) { Self() }
    }
}
```

## 关键注意事项

- **主线程约束**：`PluginProvider` 标注 `@MainActor`，所有 UI 相关扩展点也应在主线程运行。
- **注册顺序**：`order` 影响实例化顺序与根视图包裹顺序，确保依赖关系正确（例如外层装饰设置更小的 `order`）。
- **分组插件唯一性**：`isGroup == true` 的插件可被选为当前工作分组，需保证 ID 稳定且持久化。
- **持久化**：当前分组 ID 通过 `PluginRepo` 自动写入本地与 iCloud；如需额外状态持久化，请自行处理并保证线程安全。
- **并发模型**：插件本身是 `actor`，跨线程调用会自动串行化；与 UI 交互的接口务必标记 `@MainActor`。

## 快速检查清单

- 是否实现了必须的元信息与所需扩展点？  
- `register()` 是否被标记为 `@objc` 并调用了 `PluginRegistry`？  
- `order` 是否符合期望的包裹/初始化顺序？  
- 如果是分组插件，是否设置 `isGroup = true` 并验证分组切换？  
- UI 方法是否在主线程执行，是否避免了阻塞操作？

