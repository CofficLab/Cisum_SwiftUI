import SwiftUI

public extension Error {
    /// 将错误转换为视图显示
    func makeView() -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.red)
            
            Text("An error occurred")
                .font(.headline)
            
            Text(self.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
