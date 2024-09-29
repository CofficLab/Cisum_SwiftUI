import SwiftUI

struct StoreView: View {
    var body: some View {
        ScrollView {
            VStack {
                BuySetting()
//                    .padding(.horizontal)
            }
        }
        .padding(.top)
    }
}

#Preview {
    BootView {
        SettingView()
            .background(.background)
    }
    .modelContainer(Config.getContainer)
    .frame(height: 800)
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
