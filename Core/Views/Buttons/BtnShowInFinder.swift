import SwiftUI
import MagicKit

struct BtnShowInFinder: View, SuperThread {
    var url: URL
    var autoResize = true

    var body: some View {
        ControlButton(
            title: "在访达中显示",
            image: "doc.text.fill.viewfinder",
            dynamicSize: autoResize,
            onTap: {
                self.bg.async {
                    FileHelper.showInFinder(url: url)
                }
            })
    }}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
