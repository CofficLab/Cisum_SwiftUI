import SwiftUI
import CloudKit

struct DebugCommand: Commands {
    var body: some Commands {
        SidebarCommands()

        #if os(macOS)
        CommandMenu("调试") {
            Button("打开App目录") {
                let dir = AppConfig.appDir
                
                NSWorkspace.shared.open(dir)
            }
            Button("打开App Support目录") {
                guard let dir = AppConfig.appSupportDir else {
                    // 显示错误提示
                    let errorAlert = NSAlert()
                    errorAlert.messageText = "打开App Support目录出错"
                    errorAlert.informativeText = "App Support目录不存在"
                    errorAlert.alertStyle = .critical
                    errorAlert.addButton(withTitle: "好的")
                    errorAlert.runModal()
                    
                    return
                }
                
                NSWorkspace.shared.open(dir)
            }
            Button("打开文档目录") {
                guard let dir = AppConfig.localDocumentsDir else {
                    // 显示错误提示
                    let errorAlert = NSAlert()
                    errorAlert.messageText = "打开文档目录出错"
                    errorAlert.informativeText = "文档目录不存在"
                    errorAlert.alertStyle = .critical
                    errorAlert.addButton(withTitle: "好的")
                    errorAlert.runModal()
                    
                    return
                }
                
                NSWorkspace.shared.open(dir)
            }
            .keyboardShortcut("f", modifiers: [.shift, .option])
            
            Button("打开iCloud Documents") {
                NSWorkspace.shared.open(AppConfig.cloudDocumentsDir)
            }
        }
        #endif
    }
}
