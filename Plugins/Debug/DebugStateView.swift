import MagicUI
import OSLog
import SwiftData
import SwiftUI

struct DebugStateView: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var messageManager: MessageProvider
    @EnvironmentObject var man: PlayMan

    @State private var showPopover = false

    var body: some View {
        MagicButton(
            icon: "apple.terminal",
            shape: .capsule,
            action: {
                self.showPopover.toggle()
            })
            .popover(isPresented: $showPopover) {
                man.makeLogView().padding()
            }
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}

#Preview("APP") {
    RootView {
        CopyStateView()
    }
    .frame(height: 800)
}
