# PluginSettingsButton

在窗口右上角（工具栏 trailing）提供一个「设置」按钮的 Cisum 插件。

点击按钮通过 SwiftUI `openWindow` 打开设置窗口 —— 与菜单栏「设置…」（⌘,）共用同一入口。

## 能力

- 在 macOS 主窗口工具栏右侧贡献一个 `gearshape` 按钮
- 点击打开设置窗口（`cisum.settings`）
- 已打开时再次点击会激活/前置该窗口
