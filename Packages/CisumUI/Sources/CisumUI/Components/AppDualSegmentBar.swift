import SwiftUI

public struct AppDualSegmentBar: View {
    @LumiTheme private var theme

    let leadingRatio: Double
    let leadingColor: Color
    let trailingColor: Color
    let width: CGFloat
    let height: CGFloat

    public init(
        leadingRatio: Double,
        leadingColor: Color,
        trailingColor: Color,
        width: CGFloat = 120,
        height: CGFloat = 4
    ) {
        self.leadingRatio = min(max(leadingRatio, 0), 1)
        self.leadingColor = leadingColor
        self.trailingColor = trailingColor
        self.width = width
        self.height = height
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: height / 2)
                .fill(theme.textTertiary.opacity(0.18))
                .frame(width: width, height: height)

            HStack(spacing: 0) {
                Rectangle()
                    .fill(leadingColor)
                    .frame(width: width * leadingRatio, height: height)
                Spacer(minLength: 0)
            }

            HStack(spacing: 0) {
                Spacer(minLength: 0)
                Rectangle()
                    .fill(trailingColor)
                    .frame(width: width * (1 - leadingRatio), height: height)
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: height / 2, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 20) {
        AppDualSegmentBar(
            leadingRatio: 0.6,
            leadingColor: .blue,
            trailingColor: .green
        )
        AppDualSegmentBar(
            leadingRatio: 0.3,
            leadingColor: .purple,
            trailingColor: .orange
        )
        AppDualSegmentBar(
            leadingRatio: 1.0,
            leadingColor: .green,
            trailingColor: .blue
        )
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
