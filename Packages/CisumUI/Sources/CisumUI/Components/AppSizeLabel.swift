import Foundation
import SwiftUI

public struct AppSizeLabel: View {
    @LumiTheme private var theme

    let bytes: Int64
    let style: ByteCountFormatter.CountStyle

    public init(bytes: Int64, style: ByteCountFormatter.CountStyle = .file) {
        self.bytes = bytes
        self.style = style
    }

    public var body: some View {
        Text(formattedSize)
            .font(AppUI.Typography.caption1)
            .foregroundColor(theme.textSecondary)
    }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: style)
    }
}

public extension ByteCountFormatter {
    static func format(_ bytes: Int64, style: CountStyle = .file) -> String {
        string(fromByteCount: bytes, countStyle: style)
    }
}

#Preview {
    VStack(spacing: 12) {
        AppSizeLabel(bytes: 1_024)
        AppSizeLabel(bytes: 15_728_640)
        AppSizeLabel(bytes: 1_073_741_824, style: .decimal)
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
