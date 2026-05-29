import SwiftUI

/// MagicShadow组件的预览和示例
struct MagicShadowPreviews: View {
    var body: some View {
        VStack(spacing: 30) {
            // Shadow Sizes
            VStack(spacing: 15) {
                Text("Shadow Sizes")
                    .font(.title2)
                    .fontWeight(.semibold)

                HStack(spacing: 15) {
                    Group {
                        Text("XS")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .roundedMedium()
                            .shadowXs()

                        Text("SM")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .roundedMedium()
                            .shadowSm()
                    }

                    Group {
                        Text("MD")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .roundedMedium()
                            .shadowMd()

                        Text("LG")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .roundedMedium()
                            .shadowLg()
                    }
                }

                HStack(spacing: 15) {
                    Group {
                        Text("XL")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .roundedMedium()
                            .shadowXl()

                        Text("2XL")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.teal)
                            .roundedMedium()
                            .shadow2xl()

                        Text("3XL")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.indigo)
                            .roundedMedium()
                            .shadow3xl()

                        Text("None")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .roundedMedium()
                            .shadowNone()
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .roundedMedium()

            // Colored Shadows
            VStack(spacing: 15) {
                Text("Colored Shadows")
                    .font(.title2)
                    .fontWeight(.semibold)

                HStack(spacing: 20) {
                    coloredShadowButton("Blue", .blue, shadowColor: .blue)
                    coloredShadowButton("Purple", .purple, shadowColor: .purple)
                    coloredShadowButton("Pink", .pink, shadowColor: .pink)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .roundedMedium()

            // Inner Shadow
            VStack(spacing: 15) {
                Text("Inner Shadow")
                    .font(.title2)
                    .fontWeight(.semibold)

                HStack(spacing: 20) {
                    Text("Inner Effect")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .roundedMedium()
                        .shadowInner()

                    Text("With Color")
                        .font(.title3)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .roundedMedium()
                        .shadowInner()

                    Text("Rounded")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.indigo)
                        .roundedLarge()
                        .shadowInner()
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .roundedMedium()

            // Card Style
            VStack(spacing: 15) {
                Text("Card & Button Styles")
                    .font(.title2)
                    .fontWeight(.semibold)

                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("Card Title")
                            .font(.headline)
                        Text("Card with shadow")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.cyan)
                    .cardRounded()
                    .shadowCard()

                    Button("Button") {}
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink)
                        .buttonRounded()
                        .shadowButton()
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .roundedMedium()
        }
        .padding()
        .inScrollView()
        .frame(minWidth: 600, minHeight: 600)
    }

    // MARK: - Helper Methods

    private func coloredShadowButton(_ title: String, _ color: Color, shadowColor: Color) -> some View {
        Text(title)
            .font(.title3)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .roundedMedium()
            .shadowColor(shadowColor, radius: 8)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    MagicShadowPreviews()
}
#endif
