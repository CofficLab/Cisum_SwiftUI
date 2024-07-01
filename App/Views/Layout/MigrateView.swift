import OSLog
import SwiftUI

struct MigrateView: View {
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Text("Migrate")
            }

            if !appManager.flashMessage.isEmpty {
                CardView(background: BackgroundView.type4) {
                    Text(appManager.flashMessage)
                        .font(.title)
                        .foregroundStyle(.white)
                }.onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        appManager.flashMessage = ""
                    }
                }
            }

            if !appManager.fixedMessage.isEmpty {
                CardView(background: BackgroundView.type4) {
                    Text(appManager.fixedMessage)
                        .font(.title)
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("App") {
    LayoutView()
}
