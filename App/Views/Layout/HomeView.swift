import AVKit
import OSLog
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var windowManager: WindowManager
    @EnvironmentObject var appManager: AppManager

    @State private var databaseViewHeight: CGFloat = 300

    // 记录用户调整的窗口的高度
    @State private var height: CGFloat = 0
    @State private var autoResizing = false

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
                // 高度被自动修改过了，重置
                if !showDB && geo.size.height != self.height {
                    resetHeight()
                    return
                }

                // 高度不足，自动调整以展示数据库
                if showDB && geo.size.height - controlViewHeightMin <= databaseViewHeightMin {
                    increseHeightToShowDB(geo)
                    return
                }
            }
            .onChange(of: geo.size.height) {
                if autoResizing == false {
                    // 说明是用户主动调整
                    self.height = getWindowHeight()
                    os_log("\(Logger.isMain)\(self.label)Height=\(self.height)")
                }

                autoResizing = false
                
                if geo.size.height <= controlViewHeightMin + 20 {
                    appManager.showDB = false
                }
            }
            .onAppear {
                if autoResizing == false {
                    // 说明是用户主动调整
                    self.height = getWindowHeight()
                    os_log("\(Logger.isMain)\(self.label)Height=\(self.height)")
                }
            }
        }
    }

    private func resetHeight() {
        #if os(macOS)
        os_log("\(Logger.isMain)\(self.label)减少 Height 以折叠数据库视图")
        let window = NSApplication.shared.windows.first!
        var frame = window.frame
        let height = frame.size.height

        os_log("\(Logger.isMain)\(self.label)调整窗口前 Y:\(frame.origin.y) self.height=\(self.height)")

        self.autoResizing = true
        frame.origin.y = frame.origin.y + (frame.size.height - self.height)
        frame.size.height = self.height

        os_log("\(Logger.isMain)\(self.label)调整窗口后 Y:\(frame.origin.y) self.eight=\(self.height)")
        window.setFrame(frame, display: true)
        #endif
    }

    private func increseHeightToShowDB(_ geo: GeometryProxy) {
        #if os(macOS)
        os_log("\(Logger.isMain)\(self.label)增加 Height 以展开数据库视图")
        let window = NSApplication.shared.windows.first!
        var frame = window.frame
        let oldY = frame.origin.y
        let height = frame.size.height

        os_log("\(Logger.isMain)\(self.label)调整窗口前 Y=\(oldY) self.height=\(self.height)")

        let space = geo.size.height - controlViewHeightMin

        if space >= databaseViewHeightMin {
            return
        }

        self.autoResizing = true
        if geo.size.height <= controlViewHeightMin {
            frame.origin.y = oldY - databaseViewHeight
            frame.size.height = height + databaseViewHeight - space
        }

        os_log("\(Logger.isMain)\(self.label)调整窗口后 Y=\(frame.origin.y) self.height=\(self.height)")
        window.setFrame(frame, display: true)
        #endif
    }
    
    private func getWindowHeight() -> CGFloat {
        let window = NSApplication.shared.windows.first!
        var frame = window.frame
        let height = frame.size.height
        
        return height
    }
}

#Preview("Layout") {
    LayoutView()
}
