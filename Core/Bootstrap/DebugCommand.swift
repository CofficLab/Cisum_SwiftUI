import CloudKit
import SwiftUI

struct DebugCommand: Commands {
    var body: some Commands {
        SidebarCommands()

        #if os(macOS)
            CommandMenu("调试") {
                Button("打开App Support目录") { Config.appSupportDir?.openFolder() }
                Button("打开容器目录") { Config.localContainer?.openFolder() }
                Button("打开文档目录") { Config.localDocumentsDir?.openFolder() }
                Button("打开数据库目录") { Config.getDBRootDir()?.openFolder() }
                Button("打开iCloud Documents") { Config.cloudDocumentsDir?.openFolder() }
                Button("打开封面图目录") { Config.coverDir.openFolder() }
            }
        #endif
    }
}
