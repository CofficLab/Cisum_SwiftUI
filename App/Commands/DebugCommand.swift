import SwiftUI
import CloudKit

struct DebugCommand: Commands {
    private var container: String {
        AppConfig.containerIdentifier
    }
    
    var body: some Commands {
        SidebarCommands()

        #if os(macOS)
        CommandMenu("调试") {
            Button("打开文档文件夹") {
                NSWorkspace.shared.open(AppConfig.documentsDir)
            }
            .keyboardShortcut("f", modifiers: [.shift, .option])
            
            Button("打开iCloud Documents") {
                NSWorkspace.shared.open(AppConfig.documentsDir)
            }
        }
        #endif
    }
}
