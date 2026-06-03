import CisumUI
import AVKit
import MagicKit
import OSLog
import SwiftUI

struct ContentView: View, SuperLog, SuperThread {
    nonisolated static let emoji = "🖥️"
    nonisolated static let verbose = false

    @EnvironmentObject var app: AppVM
    @EnvironmentObject var p: PluginVM
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

        guard Config.canResize else { return }

        let requiredIncrease = databaseViewHeightMin - space
        self.autoResizing = true
        Config.increseHeight(requiredIncrease)
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
        if app.showDB {
            openDetailView()
        } else {
            closeDetailView()
        }
    }

    private func openDetailView() {
        guard let geo = geo else {
            setDetailVisible(true)
            return
        }

        // 高度不足时，先让窗口尺寸稳定，再展示详情面板，避免两种动画同一帧竞争。
        if geo.size.height - controlViewHeightMin <= databaseViewHeightMin {
            self.increaseHeightToShowDB(geo)
            DispatchQueue.main.async {
                guard app.showDB else { return }
                setDetailVisible(true)
            }
            return
        }

        setDetailVisible(true)
    }

    private func closeDetailView() {
        setDetailVisible(false)

        guard let geo = geo else { return }

        // 高度被自动修改过了，重置
        if !app.showDB && geo.size.height != self.height {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                resetHeight()
            }
        }
    }

    private func setDetailVisible(_ visible: Bool) {
        LumiMotion.animate(LumiMotion.enabled(LumiMotion.panelReveal, preference: motionPreference)) {
            self.isDetailVisible = visible
        }
    }

    func onAppear() {
        height = Config.getWindowHeight()

        if isDetailVisible {
            if !app.showDB {
                app.showDBView()
            }
        } else {
            isDetailVisible = app.showDB
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
