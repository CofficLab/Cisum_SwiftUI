import SwiftUI
import CloudKit

struct DebugCommand: Commands {
    var body: some Commands {
        SidebarCommands()

        #if os(macOS)
        CommandMenu("调试") {
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
            
            Button("打开容器目录") {
                guard let dir = AppConfig.localContainer else {
                    // 显示错误提示
                    let errorAlert = NSAlert()
                    errorAlert.messageText = "打开容器目录出错"
                    errorAlert.informativeText = "容器目录不存在"
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
            
            Button("打开数据库目录") {
                guard let dir = AppConfig.localDocumentsDir else {
                    // 显示错误提示
                    let errorAlert = NSAlert()
                    errorAlert.messageText = "打开数据库目录出错"
                    errorAlert.informativeText = "数据库目录不存在"
                    errorAlert.alertStyle = .critical
                    errorAlert.addButton(withTitle: "好的")
                    errorAlert.runModal()
                    
                    return
                }
                
                NSWorkspace.shared.open(dir)
            }
            
            Button("打开iCloud Documents") {
                NSWorkspace.shared.open(AppConfig.cloudDocumentsDir)
            }
            
            Button("打开音频目录") {
                NSWorkspace.shared.open(AppConfig.audiosDir)
            }
        }
        #endif
    }
}
