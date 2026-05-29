import SwiftUI

/// Padding组件的预览和示例
struct MagicPaddingPreviews: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Title
                Text("Padding Extensions (Tailwind Style)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)

                // All Sides (p-)
                VStack(spacing: 15) {
                    Text("All Sides (p-)")
                        .font(.title2)
                        .fontWeight(.semibold)

                    HStack(spacing: 15) {
                        pDemo("P0", 0, .blue)
                        pDemo("P1", 4, .blue)
                        pDemo("P2", 8, .blue)
                        pDemo("P3", 12, .blue)
                    }

                    HStack(spacing: 15) {
                        pDemo("P4", 16, .green)
                        pDemo("P5", 20, .green)
                        pDemo("P6", 24, .green)
                        pDemo("P8", 32, .green)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .roundedMedium()

                // Horizontal (px-)
                VStack(spacing: 15) {
                    Text("Horizontal (px-)")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 10) {
                        pxDemo("PX 0", 0, .orange)
                        pxDemo("PX 2", 8, .orange)
                        pxDemo("PX 4", 16, .orange)
                        pxDemo("PX 6", 24, .orange)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .roundedMedium()

                // Vertical (py-)
                VStack(spacing: 15) {
                    Text("Vertical (py-)")
                        .font(.title2)
                        .fontWeight(.semibold)

                    HStack(spacing: 15) {
                        pyDemo("PY 0", 0, .purple)
                        pyDemo("PY 2", 8, .purple)
                        pyDemo("PY 4", 16, .purple)
                        pyDemo("PY 6", 24, .purple)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .roundedMedium()

                // Individual Sides
                VStack(spacing: 15) {
                    Text("Individual Sides")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            sideDemo("T", .top, 2, .red)
                            sideDemo("R", .trailing, 2, .orange)
                            sideDemo("B", .bottom, 2, .yellow)
                            sideDemo("L", .leading, 2, .green)
                        }
                        .font(.caption)

                        HStack(spacing: 10) {
                            sideDemo("T4", .top, 4, .red)
                            sideDemo("R4", .trailing, 4, .orange)
                            sideDemo("B4", .bottom, 4, .yellow)
                            sideDemo("L4", .leading, 4, .green)
                        }
                        .font(.caption)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .roundedMedium()

                // Combinations
                VStack(spacing: 15) {
                    Text("Combinations")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 10) {
                        comboDemo("py2px4", 8, 16, .cyan)
                        comboDemo("py3px5", 12, 20, .indigo)
                        comboDemo("py4px6", 16, 24, .teal)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .roundedMedium()

                // Real World Examples
                VStack(spacing: 15) {
                    Text("Real World Examples")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 12) {
                        // Button
                        Button("Click Me") {}
                            .font(.title3)
                            .foregroundColor(.white)
                            .py2px4()
                            .background(Color.blue)
                            .roundedMedium()
                            .shadowSm()

                        // Badge
                        Text("New")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .p1()
                            .px2()
                            .background(Color.red)
                            .capsule()

                        // Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Card Title")
                                .font(.headline)
                            Text("This card demonstrates different padding combinations.")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .p4()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .roundedMedium()
                        .shadowMd()
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .roundedMedium()
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 700)
    }
}

// MARK: - Demo Helpers

func pDemo(_ title: String, _ padding: CGFloat, _ color: Color) -> some View {
    Text(title)
        .font(.caption)
        .foregroundColor(.white)
        .padding(padding)
        .background(color)
        .cornerRadius(4)
}

func pxDemo(_ title: String, _ padding: CGFloat, _ color: Color) -> some View {
    Text(title)
        .font(.caption)
        .foregroundColor(.white)
        .padding(.horizontal, padding)
        .background(color)
        .cornerRadius(4)
}

func pyDemo(_ title: String, _ padding: CGFloat, _ color: Color) -> some View {
    Text(title)
        .font(.caption)
        .foregroundColor(.white)
        .padding(.vertical, padding)
        .background(color)
        .cornerRadius(4)
}

func sideDemo(_ title: String, _ edge: Edge.Set, _ padding: CGFloat, _ color: Color) -> some View {
    Text(title)
        .font(.title3)
        .foregroundColor(title == "B" || title == "B4" ? .black : .white)
        .padding(edge, padding)
        .frame(width: 40, height: 40)
        .background(color)
}

func comboDemo(_ title: String, _ v: CGFloat, _ h: CGFloat, _ color: Color) -> some View {
    VStack {
        Text(title)
            .font(.caption)
        Text("Sample")
            .font(.caption2)
    }
    .foregroundColor(.white)
    .padding(.vertical, v)
    .padding(.horizontal, h)
    .frame(maxWidth: .infinity)
    .background(color)
}

// MARK: - Preview

#if DEBUG
#Preview {
    MagicPaddingPreviews()
}
#endif
