import SwiftUI

public struct GlassDivider: View {
    var thickness: CGFloat = 1
    var opacity: Double = 0.1

    public init(thickness: CGFloat = 1, opacity: Double = 0.1) {
        self.thickness = thickness
        self.opacity = opacity
    }

    public var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        SwiftUI.Color.clear,
                        SwiftUI.Color.white.opacity(opacity),
                        SwiftUI.Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: thickness)
    }
}

#Preview {
    VStack(spacing: 20) {
        GlassDivider()
        GlassDivider(thickness: 2, opacity: 0.2)
        GlassDivider(thickness: 1, opacity: 0.05)
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
