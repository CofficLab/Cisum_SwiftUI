import OSLog
import SwiftUI

struct BootView<Content>: View where Content: View {
    private var content: Content
    private var verbose = true
    private var label: String { "\(Logger.isMain)🌳 BootView::" }

    var dataManager: DataManager?
    var error: Error? = nil

    init(@ViewBuilder content: () -> Content) {
        self.content = content()

        do {
            try dataManager = DataManager()
        } catch let e {
            self.error = e
        }
    }

    var body: some View {
        if let e = self.error {
            FatalErrorView(error: e)
        } else {
            if let dataManager = dataManager {
                ZStack {
                    RootView()
                    content
                }
                .frame(minWidth: Config.minWidth, minHeight: Config.minHeight)
                .blendMode(.normal)
                .environmentObject(PlayMan())
                .environmentObject(AppManager())
                .environmentObject(StoreManager())
                .environmentObject(dataManager)
                .environmentObject(DB(Config.getContainer, reason: "BootView"))
            } else {
                Text("启动失败")
            }
        }
    }
}

#Preview("App") {
    AppPreview()
}
