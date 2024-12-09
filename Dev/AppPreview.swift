import SwiftUI

struct AppPreview: View {
    var body: some View {
        RootView {
            ContentView()
        }
        .frame(width: 800, height: 800)
    }
}

#Preview {
    AppPreview()
}

#Preview("Layout") {
    LayoutView()
}
