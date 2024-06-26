import SwiftUI

struct FatalErrorView: View {
    var error: Error

    var body: some View {
        ScrollView {
            VStack {
                Spacer()

                Text("遇到问题无法继续运行")
                    .font(.title)
                    .padding(.bottom, 10)

                Text("\(error.localizedDescription)")
                    .font(.subheadline)
                    .padding(.bottom, 10)

                Text(String(describing: type(of: error)))
                    .padding(.bottom, 10)

                Text(String(describing: error))

                Spacer()

                Button("退出") {
                    NSApplication.shared.terminate(self)
                }.controlSize(.extraLarge)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundView.type2A)
    }
}
