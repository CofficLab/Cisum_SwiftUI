import SwiftUI

struct BtnShowInFinder: View {
    var url: URL
        
    var body: some View {
        ControlButton(title: "在访达中显示", size: 28, systemImage: getImageName(), onTap: {
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
