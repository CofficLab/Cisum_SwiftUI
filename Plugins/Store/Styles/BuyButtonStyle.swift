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

#Preview("BuyButtonStyle") {
    Group {
        Button(action: {}) {
            Text("Buy")
                .foregroundColor(.white)
                .bold()
        }
        .buttonStyle(BuyButtonStyle())

        Button(action: {}) {
            Image(systemName: "checkmark")
                .foregroundColor(.white)
        }
        .buttonStyle(BuyButtonStyle(isPurchased: true))
    }
}

// MARK: - Preview

#Preview("Buy") {
    PurchaseView()
        .inRootView()
        .frame(height: 800)
}

#Preview("APP") {
    ContentView()
        .inRootView()
        .frame(width: 700)
        .frame(height: 800)
}
