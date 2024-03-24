import SwiftUI

struct ButtonShowInFinder: View {
    @EnvironmentObject var databaseManager: DBManager
    
    var url: URL
        
    var body: some View {
        Button {
            FileHelper.showInFinder(url: url)
        } label: {
            Label("在访达中显示", systemImage: getImageName())
                .font(.system(size: 24))
        }
    }
    
    private func getImageName() -> String {
        return "doc.text.fill.viewfinder"
    }
}
