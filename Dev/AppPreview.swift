import SwiftUI

struct AppPreview: View {
    var body: some View {
        BootView {
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
