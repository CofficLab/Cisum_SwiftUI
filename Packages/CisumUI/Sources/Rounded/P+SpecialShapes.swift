import SwiftUI

/// 特殊形状预览
struct SpecialShapesPreview: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Special Shapes")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Capsule")
                .font(.title3)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.red)
                .capsule()

            Text("Circle")
                .font(.title3)
                .foregroundColor(.white)
                .padding()
                .frame(width: 80, height: 80)
                .background(Color.yellow)
                .roundedFull()
        }
        .padding()
        .infinite()
        .roundedMedium()
    }
}

#if DEBUG
    #Preview("Special Shapes") {
        SpecialShapesPreview()
            .frame(height: 750)
    }
#endif
