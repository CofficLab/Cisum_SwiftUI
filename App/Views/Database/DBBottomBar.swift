import SwiftUI

struct DBBottomBar: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "list.bullet")
            Image(systemName: "rectangle.3.group.fill")
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 3)
    }
}

#Preview {
    DBBottomBar()
}
