import AVKit
import OSLog
import SwiftUI

struct HomeView: View {
  var play: Bool = false

  @EnvironmentObject var windowManager: WindowManager
  @EnvironmentObject var appManager: AppManager

  @State private var databaseViewHeight: CGFloat = 300

  var databaseViewHeightMin: CGFloat = 200

  var body: some View {
    #if os(macOS)
      GeometryReader { geo in
        VStack {
          ControlView().frame(height: AppConfig.controlViewHeight)

          if appManager.showDB {
            DBView()
          }
        }
        .onChange(of: appManager.showDB) { resize(geo) }
        .onChange(of: geo.size.height) { onHeightChange(geo.size.height) }
        .onAppear { onHeightChange(geo.size.height) }
      }
    #endif

    #if os(iOS)
      GeometryReader { geo in
        VStack {
          Spacer()

          ControlView()
            .padding(.horizontal, geo.size.width > 100 ? 20 : 0)
        }
      }
      .sheet(isPresented: $appManager.showDB) {
        DBView()
      }
    #endif
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

  #if os(macOS)
    private func resize(_ geo: GeometryProxy) {
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
    }
  #endif

  init() {
    os_log("\(Logger.isMain)🚩 HomeView::Init")
  }
}

#Preview("普通") {
  RootView {
    HomeView()
  }
}
