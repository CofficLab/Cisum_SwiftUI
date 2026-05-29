import SwiftUI

struct IconPreviewHelper<Content: View>: View {
    let content: Content
    let title: String

    private let sizes: [CGFloat] = [32, 44, 60, 80, 100, 200, 300, 400, 500]

    init(
        title: String = "Icon Preview",
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        ForEach(sizes, id: \.self) { size in
            VStack {
                content
                    .frame(width: size, height: size)

                Text("\(Int(size))pt")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    IconPreviewHelper(title: "Book Icon") {
        Image.makeBookIcon()
    }
}
#endif
