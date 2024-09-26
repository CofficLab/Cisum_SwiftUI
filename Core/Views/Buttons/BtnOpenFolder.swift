import SwiftUI

struct BtnOpenFolder: View {
    var url: URL
    var autoResize = false

    var body: some View {
        ControlButton(
            title: "打开",
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                FileHelper.openFolder(url: url)
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
