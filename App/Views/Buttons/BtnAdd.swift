import SwiftUI

struct BtnAdd: View {
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        Button("添加", systemImage: "plus.circle") {
            withAnimation {
                if appManager.showDB {
                    appManager.isImporting = true
                } else {
                    appManager.showDBView()
                }
            }
        }
    }
}

#Preview {
    BootView {
        VStack {
            BtnAdd()
            BtnAdd().buttonStyle(.borderedProminent)
            BtnAdd().labelStyle(.iconOnly)
            
            DBView()
        }
    }.modelContainer(Config.getContainer)
}
