import SwiftUI

struct AppPreview: View {
    var body: some View {
        RootView {
            ContentView()
        }
        .modelContainer(AppConfig.getContainer())
        .frame(width: 350)
    }
}

#Preview {
    AppPreview()
}
