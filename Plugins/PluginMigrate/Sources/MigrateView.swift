import MagicKit
import SwiftUI

public struct MigrateView: View, SuperThread {
    public init() {}

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Text("Migrate", tableName: "Migrate", bundle: .module)
            }
        }
    }
}
