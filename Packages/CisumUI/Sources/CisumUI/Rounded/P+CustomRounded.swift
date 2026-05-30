import SwiftUI

/// 自定义圆角预览
struct CustomRoundedPreview: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Custom Rounded")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Top Only")
                .font(.title3)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.indigo)
                .roundedCustom(
                    topLeading: 20,
                    topTrailing: 20,
                    bottomLeading: 0,
                    bottomTrailing: 0
                )

            Text("Bottom Only")
                .font(.title3)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.teal)
                .roundedCustom(
                    topLeading: 0,
                    topTrailing: 0,
                    bottomLeading: 20,
                    bottomTrailing: 20
                )

            Text("Diagonal")
                .font(.title3)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.cyan)
                .roundedCustom(
                    topLeading: 20,
                    topTrailing: 4,
                    bottomLeading: 4,
                    bottomTrailing: 20
                )
        }
        .padding()
        .roundedMedium()
    }
}

#if DEBUG
    #Preview("Custom Rounded") {
        CustomRoundedPreview()
            .frame(height: 600)
    }
#endif
