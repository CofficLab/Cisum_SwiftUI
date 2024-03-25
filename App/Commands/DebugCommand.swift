import SwiftUI
import CloudKit

struct DebugCommand: Commands {
    private var container: String {
        AppConfig.container
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
                let folderPath = FileManager.default.url(forUbiquityContainerIdentifier: container)?.appendingPathComponent("Documents")

                NSWorkspace.shared.open(folderPath!)
            }
        }
        #endif
    }
}