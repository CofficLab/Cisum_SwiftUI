import SwiftUI

struct BtnDownload: View {
    @EnvironmentObject var dataManager: DataManager

    var asset: PlayAsset
    var disk: any Disk { dataManager.disk }
    let queue = DispatchQueue(label: "cisum.btnDownload")

    var body: some View {
        Button {
            queue.async {
                disk.download(asset.url, reason: "点击了下载")
            }
        } label: {
            Label("下载", systemImage: getImageName())
                .font(.system(size: 24))
        }
        .disabled(asset.isLocal)
    }

    private func getImageName() -> String {
        return "icloud.and.arrow.down.fill"
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
