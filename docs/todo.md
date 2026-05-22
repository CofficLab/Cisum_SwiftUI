# CisumUI 迁移 TODO

目标：尽量让 app 的通用 UI 由 `CisumUI` 负责。业务界面优先保留现有行为，只替换可复用的视觉组件、布局容器和状态表达。`CisumUI` 缺少的组件先补到 package，再回到 app 侧替换。

## 迁移原则

- 优先替换设置页、空状态、加载状态、弹窗内容、列表行等低风险通用 UI。
- 播放控制、封面渲染、分页列表、拖放、选择状态等业务行为先保持不变。
- 每一阶段都需要能独立构建和预览，避免一次性影响播放主流程。
- 用户可见文案继续使用中文或已有本地化表。

## 第一阶段：设置页

- [ ] 将 `CisumApp/Core/Views/Layout/SettingView.swift` 从裸 `ScrollView + VStack` 整理为统一设置容器。
- [ ] 将 `CisumApp/Plugins/Storage/StorageSettingView.swift` 中的 `MagicSettingSection` / `MagicSettingRow` 替换为 `CisumUI.AppSettingsSection` / `AppSettingsRow`。
- [ ] 将 `CisumApp/Plugins/Audio-Settings/AudioSettings.swift` 迁移到 `CisumUI` 设置组件。
- [ ] 将 `CisumApp/Plugins/Book-Settings/BookSettings.swift` 迁移到 `CisumUI` 设置组件。
- [ ] 如现有 `AppSettingsRow` 不够表达右侧操作按钮或状态值，先在 `CisumUI` 增补设置行变体。

## 第二阶段：空状态和加载状态

- [ ] 用 `CisumUI.AppEmptyState` / `AppLoadingOverlay` 替换 `CisumApp/Plugins/Audio-DBView/AudioDBTips.swift` 的空仓库、加载、排序状态。
- [ ] 用 `CisumUI.AppEmptyState` / `AppLoadingOverlay` 替换 `CisumApp/Plugins/Book-DBView/Tips/BookDBTips.swift` 的空仓库、加载状态。
- [ ] 保留 macOS 打开仓库目录、iOS 添加按钮等现有平台行为。
- [ ] 如果 `AppEmptyState` 不能承载辅助操作区，给 `CisumUI` 增加 trailing/action slot。

## 第三阶段：Sheet 和确认弹窗

- [ ] 将 `CisumApp/Core/Views/Common/SheetContainer.swift` 下沉或映射到 `CisumUI` 的通用 sheet 容器。
- [ ] 为 `CisumUI` 增加通用组件：图标头部、信息行、状态横幅、底部操作按钮组。
- [ ] 用新增组件重构 `CisumApp/Plugins/Store/PurchaseView.swift`。
- [ ] 用新增组件重构 `CisumApp/Plugins/Store/RestoreView.swift`。
- [ ] 用新增组件重构 `CisumApp/Plugins/Reset/ResetConfirm.swift`。
- [ ] 保留 StoreKit 购买、恢复购买、重置设置等业务逻辑不变。

## 第四阶段：列表和条目

- [ ] 用 `CisumUI.AppListRow` / `AppContextMenuRow` / `AppSizeLabel` 替换 `CisumApp/Plugins/Audio-DBView/AudioItemView.swift` 的通用行样式。
- [ ] 评估 `CisumApp/Plugins/Book-DBView/Views/BookList.swift` 是否可迁移到统一列表行。
- [ ] 评估 `CisumApp/Plugins/Audio-Copy-macOS/CopyList.swift` 是否可迁移到统一列表行。
- [ ] 保留 `List(selection:)`、删除、分页加载、右键菜单和同步事件处理。
- [ ] 如 `AppListRow` 不能用于系统 `List` selection，给 `CisumUI` 增加专用的 selectable row。

## 第五阶段：Tab 和通用按钮

- [ ] 将 `CisumApp/Core/Views/Layout/AppTabView.swift` 的 demo 模式自定义 tab 替换为 `CisumUI.AppTabBar`。
- [ ] 正常模式的系统 `TabView` 先保留，避免破坏平台默认导航行为。
- [ ] 将常见图标按钮逐步替换为 `CisumUI.AppIconButton`。
- [ ] 如播放区需要统一按钮外观，先在 `CisumUI` 增加 `PlayerIconButton`，再迁移 app 侧按钮。

## 第六阶段：主题体系

参考 `/Users/colorfy/Code/CofficLab/Lumi` 的主题架构：主题插件通过 `addThemeContributions()` 提供 `LumiUIThemeContribution`，`ThemeService` 聚合插件贡献并写入 `LumiUIThemeRegistry`，`AppThemeVM` 管理当前主题、持久化选择并把 active theme 注入全局 UI。

- [x] 在 `SuperPlugin` 增加 `addThemeContributions() -> [LumiUIThemeContribution]` 默认实现。
- [x] 在 `PluginProvider` 增加 `getThemeContributions()`，按插件 `order` 稳定排序、去重，并重写 `ThemeSortKey`。
- [x] 增加 `ThemeService`，负责从 `PluginProvider` 同步主题贡献到 `CisumUI.LumiUIThemeRegistry`。
- [x] 增加 `AppThemeProvider` 或 `AppThemeVM`，暴露 `themes`、`currentThemeId`、`currentTheme`、`activeChromeTheme`，并提供 `selectTheme(_:)`。
- [x] 将主题选择持久化到现有 repo 或 `UserDefaults`，确保重启后恢复上次选择。
- [x] 在根视图注入主题环境：设置 `LumiUIThemeStore`、`ActiveChromeTheme.current`，并根据主题决定 `preferredColorScheme`。
- [x] 用 active theme 替换 `Config.rootBackground` 等全局背景入口，先覆盖 `RootView`、`ContentView`、`SettingView`、sheet 背景和主列表背景。
- [x] 增加主题变化通知，例如 `.cisumThemeDidChange`，方便播放器、列表、sheet 等局部视图刷新。
- [x] 增加主题设置页：用 `AppSettingsSection`、`GlassSelectionCard` 或新的 `ThemeSelectorView` 展示主题列表。
- [x] 增加状态栏或工具栏主题切换入口，参考 Lumi 的 `ThemeStatusBarPlugin`，但适配 Cisum 现有 `addStatusView()` / `addToolBarButtons()`。
- [x] 主题体系第一版只处理 app chrome 和 CisumUI 组件语义色，不引入 Lumi 的 editor theme、file icon theme 等 IDE 专属附件。
- [x] 增加 `CisumUI` 主题单元测试：空贡献报错、重复 id 报错、按 `ThemeSortKey` 排序、选择主题后同步 `LumiUIThemeStore`。

## 第七阶段：主题插件

第一批主题插件可以参考 Lumi 的独立插件目录结构：`ThemeXxxPlugin/ThemeXxxPlugin.swift` + `XxxTheme.swift` + 本地化文件。主题应该服务音频播放器场景，避免全部照搬 IDE 风格。

- [x] 新增 `ThemeCisumPlugin`：默认主题，随系统明暗适配，保持当前 Cisum 简洁、低干扰的基调。
- [x] 新增 `ThemeMidnightPlugin`：午夜深色，适合夜间听歌，低亮度蓝黑背景。
- [x] 新增 `ThemeAuroraPlugin`：极光紫，用于更有氛围的专辑封面和播放页背景。
- [x] 新增 `ThemeNebulaPlugin`：星云粉，柔和暖色，注意不要影响文本对比度。
- [x] 新增 `ThemeForestPlugin`：森林绿，适合长时间阅读有声书。
- [x] 新增 `ThemeOceanPlugin`：海洋蓝，清爽亮色/深色双模式。
- [x] 新增 `ThemeSunsetPlugin`：日落橙红，只作为点缀色，避免界面变成大面积橙色。
- [x] 新增 `ThemeMonoPlugin`：黑白高对比，优先保证可访问性。
- [x] 每个主题插件实现 `LumiAppChromeTheme`，提供 `identifier`、`displayName`、`compactName`、`description`、`iconName`、`iconColor`、accent/atmosphere/glow colors。
- [x] 每个主题插件通过 `addThemeContributions()` 返回 `LumiUIThemeContribution(appTheme:editorThemeId:)`；Cisum 暂时可使用主题 id 作为占位 `editorThemeId`。
- [ ] 为每个主题补充中文本地化名称和描述，后续统一放入对应 `.xcstrings`。
- [x] 为主题选择卡片增加小色板预览，至少展示背景色、主色、次色、文本色。
- [ ] 检查所有主题在浅色/深色、macOS/iOS、窗口大小变化下的文本对比度和背景可读性。

## 暂缓迁移

- [ ] `CisumApp/Core/Views/Layout/ControlView.swift`：播放控制布局和响应式高度强绑定，最后处理。
- [ ] `CisumApp/Core/Views/Playing/HeroView.swift`：封面、下载进度、demo 封面逻辑强绑定，最后处理。
- [ ] `CisumApp/Core/Views/Playing/BtnPlayPause.swift` 等播放按钮：等 `CisumUI` 有专用播放器按钮后再替换。

## 验证

- [x] 每阶段完成后运行 `xcodebuild -scheme Cisum -configuration Debug build`。
- [x] 覆盖 macOS 和 iOS 关键预览或模拟器构建。
- [ ] 检查设置页、仓库空状态、购买/恢复/重置弹窗、音频/图书列表的视觉一致性。
- [ ] 主题体系完成后逐个切换主题，确认 Root、设置页、仓库页、播放页、sheet、状态栏都使用同一 active theme。
