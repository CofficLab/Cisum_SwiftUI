import SwiftUI

struct BtnShowInFinder: View {
    var url: URL
    var autoResize = true

    var body: some View {
        ControlButton(
            title: "在访达中显示",
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                FileHelper.showInFinder(url: url)
            })
    }

    private func getImageName() -> String {
        return "doc.text.fill.viewfinder"
    }
}

#Preview("Layout") {
    LayoutView()
}
