import SwiftUI

struct ButtonAdd: View {
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        Button("添加", systemImage: "plus.circle") {
            appManager.showDB = true
            appManager.isImporting = true
        }
    }
}

#Preview {
    RootView {
        VStack {
            ButtonAdd()
            ButtonAdd().buttonStyle(.borderedProminent)
            ButtonAdd().labelStyle(.iconOnly)
            
            DBView()
        }
    }
}
