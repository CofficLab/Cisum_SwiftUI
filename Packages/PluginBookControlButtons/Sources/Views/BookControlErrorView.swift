import SwiftUI

struct BookControlErrorView: View {
    let error: BookControlError
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(.orange)
            Text(error.title)
                .font(.headline)
            Text(error.message)
                .font(.callout)
                .multilineTextAlignment(.center)
                .textSelection(.enabled)
            Button("Dismiss", action: dismiss)
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: 360)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 16)
        .padding()
    }
}
