import SwiftUI

struct BtnDel: View {
    @EnvironmentObject var appManager: AppProvider
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var messageManager: MessageProvider

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
                assets.forEach { asset in
                    Task {
                        do {
                            try await asset.delete()
                        } catch {
                            messageManager.alert(error.localizedDescription)
                        }
                    }
                }
            })
    }

    private func getImageName() -> String {
        return "trash"
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
