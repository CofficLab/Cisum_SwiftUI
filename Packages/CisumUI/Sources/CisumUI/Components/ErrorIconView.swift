import SwiftUI

public struct ErrorIconView: View {
    @LumiTheme private var theme

    let size: CGFloat
    let weight: Font.Weight

    public init(size: CGFloat = 16, weight: Font.Weight = .medium) {
        self.size = size
        self.weight = weight
    }

    public var body: some View {
        Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: size, weight: weight))
            .foregroundColor(theme.error)
    }
}

#Preview {
    VStack(spacing: 24) {
        ErrorIconView(size: 16)
        ErrorIconView(size: 32, weight: .bold)
        ErrorIconView(size: 48)
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
