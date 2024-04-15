import SwiftUI

struct ButtonCancelSelected: View {
    var action: () -> Void
        
    var body: some View {
        Button {
            action()
        } label: {
            Label("取消", systemImage: getImageName())
                .font(.system(size: 24))
        }
    }
    
    private func getImageName() -> String {
        return "clipboard.fill"
    }
}

#Preview("Layout") {
    LayoutView()
}
