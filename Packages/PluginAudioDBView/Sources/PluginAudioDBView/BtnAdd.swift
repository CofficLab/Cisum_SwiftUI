import MagicKit
import SwiftUI

struct BtnAdd: View {
    @Environment(\.audioDBDependencies) private var dependencies

    var body: some View {
        Button(
            action: { dependencies.isImporting.wrappedValue = true },
            label: {
                Label(
                    title: { Text("添加", tableName: "Audio-DBView") },
                    icon: { Image(systemName: "plus.circle") }
                )
            }
        )
    }
}
