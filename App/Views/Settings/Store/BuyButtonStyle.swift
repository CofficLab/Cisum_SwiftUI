import StoreKit
import SwiftUI

struct BuyButtonStyle: ButtonStyle {
    let isPurchased: Bool
    let hovered: Bool

    init(isPurchased: Bool = false, hovered: Bool = false) {
        self.isPurchased = isPurchased
        self.hovered = hovered
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        var bgColor: Color = isPurchased ? Color.green : Color.blue
        bgColor = configuration.isPressed ? bgColor.opacity(0.7) : bgColor.opacity(1)

        return configuration.label
            .frame(width: 80)
            .padding(10)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .scaleEffect(hovered ? 1.03 : 1.0)
    }
}

#Preview {
    Group {
        Button(action: {}) {
            Text("Buy")
                .foregroundColor(.white)
                .bold()
        }
        .buttonStyle(BuyButtonStyle())
        .previewDisplayName("普通")

        Button(action: {}) {
            Image(systemName: "checkmark")
                .foregroundColor(.white)
        }
        .buttonStyle(BuyButtonStyle(isPurchased: true))
        .previewDisplayName("已购买")
    }
}
