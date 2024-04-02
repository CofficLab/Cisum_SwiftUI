import AVKit
import OSLog
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var windowManager: WindowManager
    @EnvironmentObject var appManager: AppManager

    @State private var databaseViewHeight: CGFloat = 300

    var showDB: Bool {appManager.showDB}
    var databaseViewHeightMin = AppConfig.databaseViewHeightMin

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ControlView()
                    .frame(height: getControlViewHeight(geo))

                if showDB {
                    DBView()
                }
            }
            .onChange(of: showDB) { if AppConfig.canResize {resize(geo)} }
            .onChange(of: geo.size.height) { onHeightChange(geo.size.height) }
            .onAppear { onHeightChange(geo.size.height) }
        }
    }
    
    private func getControlViewHeight(_ geo: GeometryProxy) -> Double {
            if AppConfig.canResize {
                return AppConfig.controlViewHeight
            }
            
            if showDB {
                return geo.size.height * 0.4
            }
        
        return geo.size.height
    }

    private func onHeightChange(_ height: CGFloat) {
        if height > AppConfig.controlViewHeight {
            appManager.showDB = true
            databaseViewHeight = height - AppConfig.controlViewHeight
            if databaseViewHeight < databaseViewHeightMin {
                databaseViewHeight = databaseViewHeightMin
            }
        }
    }

    private func resize(_ geo: GeometryProxy) {
        #if os(macOS)
        os_log("\(Logger.isMain)🖥️ HomeView::appManager.showDatabase 变为 \(appManager.showDB)")
        let window = NSApplication.shared.windows.first!
        var frame = window.frame
        let oldY = frame.origin.y
        let height = frame.size.height

        if appManager.showDB {
            if geo.size.height <= AppConfig.controlViewHeight {
                AppConfig.logger.app.debug("增加 Height 以展开数据库视图")
                frame.origin.y = oldY - databaseViewHeight
                frame.size.height = height + databaseViewHeight
            }
        } else {
            AppConfig.logger.app.debug("🖥️ HomeView::减少 Height 以折叠数据库视图")
            frame.origin.y = oldY + (frame.size.height - AppConfig.controlViewHeight)
            frame.size.height = AppConfig.controlViewHeight
        }

        os_log("\(Logger.isMain)🖥️ HomeView::自动调整窗口 oldY:\(oldY) y:\(frame.origin.y))")
        window.setFrame(frame, display: true)
        #endif
    }

    init() {
//    os_log("\(Logger.isMain)🚩 HomeView::Init")
    }
}

#Preview("普通") {
    RootView {
        HomeView()
    }
}
