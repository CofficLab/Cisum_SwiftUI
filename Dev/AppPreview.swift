import SwiftUI

struct AppPreview: View {
    var body: some View {
        RootView {
            ContentView()
        }
        .modelContainer(Config.getContainer)
    }
}

#Preview {
    AppPreview()
}

#Preview("Layout") {
    LayoutView()
}
