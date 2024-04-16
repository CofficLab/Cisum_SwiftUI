import AVKit
import OSLog
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var windowManager: WindowManager
    @EnvironmentObject var appManager: AppManager

    @State private var databaseViewHeight: CGFloat = 300
    
    // 记录用户调整的窗口的高度
    @State private var height: CGFloat = 0
    @State private var heightChangedByUser = false

    var showDB: Bool { appManager.showDB }
    var controlViewHeightMin = AppConfig.controlViewMinHeight
    var databaseViewHeightMin = AppConfig.databaseViewHeightMin
    var label = "🖥️ HomeView::"

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ControlView()

                if showDB {
                    DBView()
                }
            }
            .onChange(of: showDB) {
                resize(geo)
            }
            .onChange(of: geo.size.height, {
                onHeightChange(geo.size.height)
            })
        }
    }

    private func onHeightChange(_ height: CGFloat) {
        // 高度小到一定程度，隐藏数据库
        if height <= controlViewHeightMin {
            appManager.showDB = false
        }
    }

    private func resize(_ geo: GeometryProxy) {
        #if os(macOS)
        os_log("\(Logger.isMain)\(self.label)showDatabase 变为 \(showDB)")
        let window = NSApplication.shared.windows.first!
        var frame = window.frame
        let oldY = frame.origin.y
        let height = frame.size.height

        os_log("\(Logger.isMain)\(self.label)调整窗口前 Y:\(oldY)")

        let space = geo.size.height - controlViewHeightMin

        if space >= databaseViewHeightMin {
            return
        }

        if appManager.showDB {
            if geo.size.height <= controlViewHeightMin {
                os_log("\(Logger.isMain)\(self.label)增加 Height 以展开数据库视图")
                frame.origin.y = oldY - databaseViewHeight
                frame.size.height = height + databaseViewHeight - space
            }
        } else {
            os_log("\(self.label)减少 Height 以折叠数据库视图")
            frame.origin.y = oldY + (frame.size.height - controlViewHeightMin)
            frame.size.height = controlViewHeightMin
        }

        os_log("\(Logger.isMain)\(self.label)调整窗口后 Y:\(frame.origin.y))")
        window.setFrame(frame, display: true)
        #endif
    }
}

#Preview("Layout") {
    LayoutView()
}
