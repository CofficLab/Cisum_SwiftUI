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
                    self.height = DeviceConfig.getWindowHeight()
                    // os_log("\(Logger.isMain)\(self.label)Height=\(self.height)")
                }

                autoResizing = false

                if geo.size.height <= controlViewHeightMin + 20 {
                    appManager.closeDBView()
                }
            }
            .onAppear {
                if autoResizing == false {
                    // 说明是用户主动调整
                    self.height = DeviceConfig.getWindowHeight()
                    os_log("\(Logger.isMain)\(self.label)Height=\(self.height)")
                }
            }
        }
    }
}

extension HomeView {
    private func increseHeightToShowDB(_ geo: GeometryProxy) {
        os_log("\(Logger.isMain)\(self.label)增加 Height 以展开数据库视图")
        let space = geo.size.height - controlViewHeightMin

        if space >= databaseViewHeightMin {
            return
        }

        self.autoResizing = true
        DeviceConfig.increseHeight(databaseViewHeight - space)
    }

    private func resetHeight() {
        os_log("\(Logger.isMain)\(self.label)减少 Height 以折叠数据库视图")
        self.autoResizing = true
        DeviceConfig.setHeight(self.height)
    }
}

#Preview("Layout") {
    LayoutView()
}

#Preview("iPhone 15") {
    LayoutView(device: .iPhone_15)
}

#Preview("iPad") {
    LayoutView(device: .iPad_mini)
}
