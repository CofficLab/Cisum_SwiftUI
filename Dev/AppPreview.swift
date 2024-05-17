import SwiftUI

struct AppPreview: View {
    var body: some View {
        RootView {
            ContentView()
        }
        .modelContainer(AppConfig.getContainer)
    }
}

#Preview {
    AppPreview()
}

#Preview("Layout") {
    LayoutView()
}
