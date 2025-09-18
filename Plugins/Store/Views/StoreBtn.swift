import Foundation
import MagicCore
import MagicAlert
import MagicUI
import OSLog
import SwiftUI

struct StoreBtn: View, SuperLog {
    @EnvironmentObject private var m: MagicMessageProvider
    
    private var asToolbarItem: Bool = false
    private var icon: String = "app.gift"
    
    init(asToolbarItem: Bool = false) {
        self.asToolbarItem = asToolbarItem
    }

    var body: some View {
        Group {
            if asToolbarItem {
                Button {
                    action()
                } label: {
                    Label {
                        Text("Store")
                    } icon: {
                        Image(systemName: icon)
                    }
                }
                .buttonStyle(.plain)
            } else {
                MagicButton.simple(icon: icon, size: .auto, action: {
                    action()
                })
                .magicTitle("商店")
                .magicShape(.roundedRectangle)
                .frame(width: 150)
                .frame(height: 50)
            }
        }
    }
    
    private func action() -> Void {
    }
}

// MARK: - Preview

#Preview {
    RootView {
        VStack {
            StoreBtn()
            StoreBtn(asToolbarItem: true)
        }
    }
    .frame(height: 500)
    .frame(width: 500)
}

#Preview("App") {
    RootView {
        ContentView()
    }
}
