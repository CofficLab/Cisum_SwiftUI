import SwiftUI

/// MagicMask组件的预览和示例
struct MaskPreviews: View {
    let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 16),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Title
                Text("Magic Mask Extensions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)

                // Shape Masks
                VStack(spacing: 15) {
                    Text("Shape Masks")
                        .font(.title2)
                        .fontWeight(.semibold)

                    LazyVGrid(columns: columns, spacing: 16) {
                        maskExample("Squircle", systemName: "square.rounded", color: .blue)
                            .magicMaskSquircle()

                        maskExample("Heart", systemName: "heart.fill", color: .pink)
                            .magicMaskHeart()

                        maskExample("Hexagon", systemName: "hexagon.fill", color: .purple)
                            .magicMaskHexagon()

                        maskExample("Hexagon 2", systemName: "hexagon.fill", color: .indigo)
                            .magicMaskHexagon2()

                        maskExample("Decagon", systemName: "decagon.fill", color: .orange)
                            .magicMaskDecagon()

                        maskExample("Pentagon", systemName: "pentagon.fill", color: .yellow)
                            .magicMaskPentagon()

                        maskExample("Diamond", systemName: "diamond.fill", color: .cyan)
                            .magicMaskDiamond()

                        maskExample("Square", systemName: "square.fill", color: .green)
                            .magicMaskSquare()

                        maskExample("Circle", systemName: "circle.fill", color: .red)
                            .magicMaskCircle()

                        maskExample("Star", systemName: "star.fill", color: .yellow)
                            .magicMaskStar()

                        maskExample("Star 2", systemName: "star.fill", color: .orange)
                            .magicMaskStar2()

                        maskExample("Triangle", systemName: "triangle.fill", color: .mint)
                            .magicMaskTriangle()

                        maskExample("Triangle 2", systemName: "triangle.fill", color: .teal)
                            .magicMaskTriangle2()

                        maskExample("Triangle 3", systemName: "triangle.fill", color: .blue)
                            .magicMaskTriangle3()

                        maskExample("Triangle 4", systemName: "triangle.fill", color: .indigo)
                            .magicMaskTriangle4()
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .roundedMedium()

                // Modifier Masks
                VStack(spacing: 15) {
                    Text("Modifier Masks")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 16) {
                        modifierExample("Half 1 (Left)", systemName: "arrow.left.to.line", color: .blue)
                            .magicMaskHalf1()

                        modifierExample("Half 2 (Right)", systemName: "arrow.right.to.line", color: .green)
                            .magicMaskHalf2()
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .roundedMedium()
            }
            .padding()
            .inScrollView()
        }
    }

    // MARK: - Helper Views

    private func maskExample(_ title: String, systemName: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: systemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func modifierExample(_ title: String, systemName: String, color: Color) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: systemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    MaskPreviews()
        .frame(height: 700)
        .frame(width: 500)
}
#endif
