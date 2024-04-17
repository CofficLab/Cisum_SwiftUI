import SwiftUI

struct BtnAdd: View {
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        Button("添加", systemImage: "plus.circle") {
            withAnimation {
                if appManager.showDB {
                    appManager.isImporting = true
                } else {
                    appManager.showDB = true
                }
            }
        }
    }
}

#Preview {
    RootView {
        VStack {
            BtnAdd()
            BtnAdd().buttonStyle(.borderedProminent)
            BtnAdd().labelStyle(.iconOnly)
            
            DBView()
        }
    }.modelContainer(AppConfig.getContainer())
}
