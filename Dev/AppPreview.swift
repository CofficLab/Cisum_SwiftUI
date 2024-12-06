import SwiftUI

struct AppPreview: View {
    var body: some View {
        BootView {
            ContentView()
        }
        .modelContainer(Config.getContainer)
        .frame(width: 800, height: 800)
    }
}

#Preview {
    AppPreview()
}

#Preview("Layout") {
    LayoutView()
}
