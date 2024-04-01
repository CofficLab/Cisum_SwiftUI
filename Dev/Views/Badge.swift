import SwiftUI

struct Badge: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.system(size: 80))
            .padding(40)
            .background(BackgroundView.type3)
            .cornerRadius(48)
    }
}

#Preview {
    ZStack {
        Badge(title: "1")
    }
    .frame(width: 200, height: 200)
    .background(BackgroundView.type1)
}
