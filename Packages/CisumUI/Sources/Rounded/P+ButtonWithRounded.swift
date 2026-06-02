import SwiftUI

/// 带圆角扩展的按钮预览
struct ButtonWithRoundedPreview: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Button with Rounded Extensions")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                Text("Default (6pt)")
                    .inButtonNoAction()

                Text("Small (4pt)")
                    .inButtonNoAction()
                    .background(.blue)
                    .roundedSmall()

                Text("Medium (8pt)")
                    .inButtonNoAction()
                    .background(.green)
                    .roundedMedium()

                Text("Large (16pt)")
                    .inButtonNoAction()
                    .background(.orange)
                    .roundedLarge()

                Text("XLarge (24pt)")
                    .inButtonNoAction()
                    .background(.red)
                    .roundedExtraLarge()

                HStack {
                    Image.play
                    Text("Capsule")
                }
                .inButtonNoAction()
                .background(.blue)
                .capsule()

                HStack {
                    Image.stop
                    Text("Circle")
                }
                .frame(width: 120)
                .frame(height: 120)
                .inButtonNoAction()
                .background(.red)
                .roundedFull()
            }
        }
        .padding()
        .roundedMedium()
    }
}

#if DEBUG
    #Preview("Button with Rounded") {
        ButtonWithRoundedPreview()
            .frame(height: 600)
            .frame(width: 500)
    }
#endif
