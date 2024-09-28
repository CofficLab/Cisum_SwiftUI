import SwiftUI
import MagicKit

struct BtnShowInFinder: View, SuperThread {
    var url: URL
    var autoResize = true

    var body: some View {
        ControlButton(
            title: "在访达中显示",
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                self.bg.async {
                    FileHelper.showInFinder(url: url)
                }
            })
    }

    private func getImageName() -> String {
        return "doc.text.fill.viewfinder"
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
