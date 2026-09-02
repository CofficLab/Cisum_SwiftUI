import SwiftUI

/// Cisum 应用命令装配（对齐 Lumi `FactoryLumi/AppCommands.swift`）。
///
/// 菜单栏命令的装配集中在 Factory 包内完成；宿主 App 只需
/// `.commands { FactoryCisum.makeCommands() }`，不需要关心命令从哪来。
public struct CisumAppCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    public init() {}

    public var body: some Commands {
        // 菜单栏「设置…」入口（⌘,）——对齐 Lumi 的设置窗口入口。
        CommandGroup(replacing: .appSettings) {
            Button("设置…") {
                openWindow(id: AppBootstrap.settingsWindowID)
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}
