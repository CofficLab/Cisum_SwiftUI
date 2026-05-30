import SwiftUI

public extension Error {
    /// Render an error as a compact SwiftUI view.
    func makeView() -> AnyView {
        AnyView(VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.red)

            Text("发生错误")
                .font(.headline)

            Text(localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding())
    }
}
