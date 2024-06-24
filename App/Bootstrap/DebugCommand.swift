import CloudKit
import SwiftUI

struct DebugCommand: Commands {
    var body: some Commands {
        SidebarCommands()

        #if os(macOS)
        CommandMenu("调试") {
            Button("打开App Support目录") { openUrl(Config.appSupportDir) }
            Button("打开容器目录") { openUrl(Config.localContainer) }
            Button("打开文档目录") { openUrl(Config.localDocumentsDir) }
            Button("打开数据库目录") { openUrl(Config.localDocumentsDir) }
            Button("打开iCloud Documents") { openUrl(Config.cloudDocumentsDir) }
            Button("打开音频目录") { openUrl(Config.disk.root) }
            Button("打开封面图目录") { openUrl(Config.coverDir) }
        }
        #endif
    }

    private func openUrl(_ url: URL?) {
        #if os(macOS)
        guard let dir = url else {
            // 显示错误提示
            let errorAlert = NSAlert()
            errorAlert.messageText = "打开目录出错"
            errorAlert.informativeText = "目录不存在"
            errorAlert.alertStyle = .critical
            errorAlert.addButton(withTitle: "好的")
            errorAlert.runModal()

            return
        }

        NSWorkspace.shared.open(dir)
        #endif
    }
}
