import SwiftUI

/// 按钮扩展预览
struct ButtonExtensionPreview: View {
    @State private var counter = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Button Extension Examples")
                .font(.title2)
                .fontWeight(.semibold)
                .withDivider(spacing: 10)

            Text("Text as Button")
                .inButtonNoAction()
                .buttonStyle(.borderedProminent)

            HStack {
                Image(systemName: "star.fill")
                Text("Icon + Text")
            }
            .inButtonNoAction()
            .buttonStyle(.bordered)

            Text("Custom Style")
                .padding()
                .inButtonNoAction()
                .background(.blue)
                .foregroundColor(.white)
                .roundedMedium()

            VStack {
                Text("With Action (Tap me!)")
                    .padding()
                    .background(.purple)
                    .foregroundColor(.white)
                    .roundedMedium()
                    .inButtonWithAction {
                        counter += 1
                    }
                
                Text("Counter: \(counter)")
                    .font(.headline)
                    .padding()
                    .inCardUltraThin()
            }
            .padding()
            .inBackgroundMint(0.2)

            Text("Capsule")
                .inButtonNoAction()
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.green)
                .foregroundColor(.white)
                .capsule()

            Text("Circle")
                .frame(width: 80, height: 80)
                .background(.orange)
                .foregroundColor(.white)
                .roundedFull()
                .inButtonNoAction()
        }
        .padding()
        .infinite()
        .inScrollView()
    }
}

#if DEBUG
    #Preview("Button Extensions") {
        ButtonExtensionPreview()
            .frame(height: 700)
            .frame(width: 400)
    }
#endif
