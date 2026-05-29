import SwiftUI

// MARK: - Preview
struct BackgroundGroupPreview: View {
    let columns = 6
    let itemSize: CGFloat = 120
    let spacing: CGFloat = 8
    
    var body: some View {
        ScrollView([.vertical, .horizontal], showsIndicators: true) {
            LazyVStack(spacing: spacing) {
                ForEach(1 ... 10, id: \.self) { i in
                    let opacity = Double(11 - i) / 10.0  // 倒置：从 1.0 到 0.1
                    
                    LazyHStack(spacing: spacing) {
                        ForEach(Array(MagicBackgroundGroup.GradientName.allCases.enumerated()), id: \.offset) { index, gradientName in
                            ZStack {
                                MagicBackgroundGroup(for: gradientName)
                                    .opacity(opacity)
                                    .frame(width: itemSize, height: itemSize) // 正方形
                                    .cornerRadius(8)
                                
                                textOverlay(for: gradientName, opacity: opacity)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Private Helpers
extension BackgroundGroupPreview {
    private func textOverlay(for gradientName: MagicBackgroundGroup.GradientName, opacity: Double) -> some View {
        VStack(spacing: 4) {
            Spacer()
            
            Text(gradientName.rawValue)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 4)
            
            Text("\(String(format: "%.1f", opacity))")
                .font(.caption2)
                .fontWeight(.bold)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
#Preview {
    BackgroundGroupPreview()
        .frame(width: 600)
        .frame(height: 800)
}
#endif
