import SwiftUI

struct AppPreview: View {
    var body: some View {
        RootView {
            ContentView()
        }
        .modelContainer(AppConfig.getContainer())
        .frame(width: AppConfig.minWidth, height: AppConfig.minHeight)
    }
}

#Preview {
    AppPreview()
}

#Preview("Layout") {
    LayoutPreview()
}
