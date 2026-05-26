import CisumUI
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
    @LumiMotionPreferenceReader private var motionPreference
    @State private var databaseViewHeight: CGFloat = 300

    // 记录用户调整的窗口的高度
    @State private var height: CGFloat = 0
    @State private var autoResizing = false
    @State private var geo: GeometryProxy?

    @State var isDetailVisible: Bool = false

    var controlViewHeightMin = Config.controlViewMinHeight
    var databaseViewHeightMin = Config.databaseViewHeightMin

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ControlView()
                    .frame(height: isDetailVisible ? Config.controlViewMinHeight : geo.size.height)

                if isDetailVisible {
                    AppTabView()
                        .appPanelRevealTransition(preference: motionPreference)
                }

                StatusView()
            }
            .animation(
                LumiMotion.enabled(LumiMotion.panelReveal, preference: motionPreference),
                value: isDetailVisible
            )
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear { handleOnAppear(geo) }
            .onChange(of: app.showDB, onChangeOfShowDB)
            .onChange(of: geo.size.height, onChangeOfGeoHeight)
        }
        .cisumInfinite()
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
        LumiMotion.animate(LumiMotion.enabled(LumiMotion.panelReveal, preference: motionPreference)) {
            self.isDetailVisible = app.showDB
        }

        guard let geo = geo else { return }

        // 高度被自动修改过了，重置
        if !app.showDB && geo.size.height != self.height {
            resetHeight()
            return
        }

        // 高度不足，自动调整以展示数据库
        if app.showDB && geo.size.height - controlViewHeightMin <= databaseViewHeightMin {
            self.increaseHeightToShowDB(geo)
            return
        }
    }

    func onAppear() {
        height = Config.getWindowHeight()
        
        if self.isDetailVisible != app.showDB {
            if self.isDetailVisible {
                app.showDBView()
            } else {
                app.closeDBView()
            }
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
    ContentLayout()
        .showDetail()
        .inRootView()
        .withDebugBar()
}

#Preview("App - HideTab") {
    ContentLayout()
        .hideDetail()
        .inRootView()
        .withDebugBar()
}

#Preview("App Store Album Art") {
    AppStoreAlbumArt()
        .cisumPreviewContainer(.cisumMacBook13, scale: 0.5)
}
