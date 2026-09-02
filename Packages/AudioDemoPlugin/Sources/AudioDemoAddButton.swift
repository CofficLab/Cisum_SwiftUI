import CisumUI
import AudioScenePlugin
import SwiftUI

struct AudioDemoAddButton: View {
    @Environment(\.appIsImporting) private var isImporting

    var body: some View {
        Button(
            action: { isImporting.wrappedValue = true },
            label: {
                Label(
                    title: { Text("Add", bundle: .module) },
                    icon: { Image(systemName: "plus.circle") }
                )
            }
        )
    }
}
