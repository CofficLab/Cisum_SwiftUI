import SwiftUI

struct BtnDel: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var dataManager: DataManager

    var disk: any Disk { dataManager.disk }
    var assets: [PlayAsset]
    var callback: () -> Void = {}
    var autoResize = false

    var body: some View {
        ControlButton(
            title: "删除 \(assets.count) 个",
            tips: "彻底删除，不可恢复",
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                delete()
            })
    }

    private func getImageName() -> String {
        return "trash"
    }
    
    private func delete() {
        Task {
            // appManager.stateMessage = "正在删除 \(audios.count) 个"

            let isPlaying = playMan.isPlaying

            guard let lastAssetURL = assets.last?.url else {
                return
            }

            let next = disk.next(lastAssetURL)

            disk.deleteFiles(assets.map { $0.url })

            if let asset = playMan.asset, assets.map({ $0.url }).contains(asset.url) {
                if isPlaying, let next = next {
                    playMan.play(next.toPlayAsset(), reason: "删除了")
                } else {
                    playMan.prepare(next?.toPlayAsset())
                }
            }

            appManager.setFlashMessage("已删除")
            appManager.cleanStateMessage()
            callback()
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
