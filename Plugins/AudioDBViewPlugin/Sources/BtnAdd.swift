import MagicKit
import SwiftUI

struct BtnAdd: View {
    @Environment(\.audioDBDependencies) private var dependencies

    var body: some View {
        Button(
            action: { dependencies.isImporting.wrappedValue = true },
            label: {
                Label(
                    title: { Text("Add", bundle: .module) },
                    icon: { Image(systemName: "plus.circle") }
                )
            }
        )
    }
}
