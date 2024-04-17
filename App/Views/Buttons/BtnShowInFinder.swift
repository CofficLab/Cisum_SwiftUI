import SwiftUI

struct BtnShowInFinder: View {
    var url: URL
    var dynamicSize = true

    var body: some View {
        ControlButton(
            title: "在访达中显示",
            systemImage: getImageName(),
            dynamicSize: dynamicSize,
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
