import SwiftUI
import SwiftData

struct BottomBar: View {
    var body: some View {
        HStack(spacing: 0) {
            BottomViewType()

            Spacer()

            BottomCopyState()
            
            Spacer()
        }
        .frame(height: 25)
        .background(BackgroundView.type2A.opacity(0.5))
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
