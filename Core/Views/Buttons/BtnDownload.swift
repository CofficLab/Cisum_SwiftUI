import SwiftUI
import MagicKit

struct BtnDownload: View, SuperThread {
    @EnvironmentObject var dataManager: DataProvider
    @EnvironmentObject var l: LayoutProvider

    var asset: PlayAsset
    var disk: (any Disk)? { l.current.getDisk() }
    let queue = DispatchQueue(label: "cisum.btnDownload")

    var body: some View {
        Button {
            handleDownload()
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

// MARK: Event Handler

extension BtnDownload {
    private func handleDownload() {
        guard let disk else { return }
        self.bg.async {
            disk.download(asset.url, reason: "点击了下载")
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
