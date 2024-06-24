import OSLog
import SwiftUI

struct BtnLike: View {
  @EnvironmentObject var dataManager: DataManager

  @State var like = false

  var asset: PlayAsset
  var disk: Disk { dataManager.disk }
  var autoResize = false
  var title: String { asset.like ? "取消喜欢" : "标记喜欢" }
  var label: String { "\(Logger.isMain)❤️ BtnLike::" }

  var body: some View {
    ControlButton(
      title: title,
      image: getImageName(),
      dynamicSize: autoResize,
      onTap: {
        Task {
          //                    await db.toggleLike(asset.url)
        }
      }
    )
    .onAppear {
      self.like = asset.like
    }
    .onChange(of: asset.url) {
      self.like = asset.like
    }
    .onReceive(
      NotificationCenter.default.publisher(for: Notification.Name.AudioUpdatedNotification),
      perform: { notification in
        let data = notification.userInfo as! [String: Audio]
        let audio = data["audio"]!
        self.like = audio.like
      })
  }

  private func getImageName() -> String {
    return like ? "star.fill" : "star"
  }
}

#Preview("App") {
  AppPreview()
    .frame(height: 800)
}

#Preview("Layout") {
  LayoutView()
}
