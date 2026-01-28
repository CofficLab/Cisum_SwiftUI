import AVKit
import MagicKit
import OSLog
import SwiftUI

struct ContentView: View, SuperLog, SuperThread {
    nonisolated static let emoji = "🖥️"
    nonisolated static let verbose = false

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var p: PluginProvider
    @Environment(\.demoMode) var isDemoMode
    @Environment(\.showTabView) var showTabView
    @State private var databaseViewHeight: CGFloat = 300

    // 记录用户调整的窗口的高度
    @State private var height: CGFloat = 0
    @State private var autoResizing = false
    @State private var geo: GeometryProxy?

    var showDB: Bool { app.showDB }
    var controlViewHeightMin = Config.controlViewMinHeight
    var databaseViewHeightMin = Config.databaseViewHeightMin

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ControlView()
                    .frame(height: showDB ? Config.controlViewMinHeight : geo.size.height)

                if showDB {
                    AppTabView()
                }

                StatusView()
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear { handleOnAppear(geo) }
            .onChange(of: showDB, onChangeOfShowDB)
            .onChange(of: geo.size.height, onChangeOfGeoHeight)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Setter

extension ContentView {
    func increaseHeightToShowDB(_ geo: GeometryProxy) {
        let space = geo.size.height - controlViewHeightMin

        if space >= databaseViewHeightMin {
            return
        }

        self.autoResizing = true
    }

    func resetHeight(verbose: Bool = false) {
        self.autoResizing = true
        Config.setHeight(self.height)
    }
}

// MARK: - Event Handler

extension ContentView {
    func handleOnAppear(_ geo: GeometryProxy) {
        self.geo = geo
        onAppear()
    }

    func onChangeOfGeoHeight() {
        guard let geo = geo else { return }

        if autoResizing == false {
            // 说明是用户主动调整
            self.height = Config.getWindowHeight()
        }

        autoResizing = false

        if geo.size.height <= controlViewHeightMin + 20 {
            app.closeDBView()
        }
    }

    func onChangeOfShowDB() {
        guard let geo = geo else { return }

        // 高度被自动修改过了，重置
        if !showDB && geo.size.height != self.height {
            resetHeight()
            return
        }

        // 高度不足，自动调整以展示数据库
        if showDB && geo.size.height - controlViewHeightMin <= databaseViewHeightMin {
            self.increaseHeightToShowDB(geo)
            return
        }
    }

    func onAppear() {
        height = Config.getWindowHeight()

        if showTabView && app.showDB == false {
            app.showDBView()
        }
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}

#Preview("App - ShowTab") {
    ContentView()
        .inRootView()
        .showTabView()
        .withDebugBar()
}

#Preview("App Store Album Art") {
    AppStoreAlbumArt()
        .inMagicContainer(.macBook13, scale: 0.5)
}
