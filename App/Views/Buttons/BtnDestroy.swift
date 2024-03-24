import SwiftUI

struct BtnDestroy: View {
    @EnvironmentObject var db: DBManager
    
    var body: some View {
        Button {
            db.destroy()
        } label: {
            Label("清空", systemImage: getImageName())
                .font(.system(size: 24))
        }
    }
    
    private func getImageName() -> String {
        return "icloud.and.arrow.down.fill"
    }
}
