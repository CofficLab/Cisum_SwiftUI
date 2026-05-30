import SwiftUI

/// 圆角尺寸预览
struct RoundedSizesPreview: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Rounded Sizes")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Small (4pt)")
                .font(.title3)
                .foregroundColor(.white)
                .padding()
                .infiniteWidth()
                .background(.blue)
                .roundedSmall()

            Text("Medium (8pt)")
                .font(.title3)
                .foregroundColor(.white)
                .padding()
                .infiniteWidth()
                .background(.green)
                .roundedMedium()

            Text("Large (16pt)")
                .font(.title3)
                .foregroundColor(.white)
                .padding()
                .infiniteWidth()
                .background(.orange)
                .roundedLarge()

            Text("XLarge (24pt)")
                .font(.title3)
                .foregroundColor(.white)
                .padding()
                .infiniteWidth()
                .background(.purple)
                .roundedExtraLarge()

            Text("Full (Circle)")
                .font(.title3)
                .foregroundColor(.white)
                .padding()
                .frame(width: 120, height: 120)
                .background(.pink)
                .roundedFull()
        }
        .padding()
        .infinite()
        .inCard()
        .roundedMedium()
    }
}

#if DEBUG
    #Preview("Rounded Sizes") {
        RoundedSizesPreview()
            .frame(height: 700)
    }
#endif
