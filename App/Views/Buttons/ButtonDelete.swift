import SwiftUI

struct ButtonDelete: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @EnvironmentObject var appManager: AppManager
    
    var url: URL
        
    var body: some View {
        Button {
            Task {
                await databaseManager.delete(urls: [url])
                appManager.setFlashMessage("\(url.lastPathComponent) 已经删除")
            }
        } label: {
            Label("删除", systemImage: getImageName())
                .font(.system(size: 24))
        }
    }
    
    private func getImageName() -> String {
        return "trash"
    }
}
