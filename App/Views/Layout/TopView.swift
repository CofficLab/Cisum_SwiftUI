import SwiftUI

struct TopView: View {
    var body: some View {
        HStack {
            Spacer()
            BtnBuy().labelStyle(.iconOnly)
        }.padding(.horizontal)
    }
}

#Preview {
    AppPreview()
}

#Preview {
    TopView()
}
