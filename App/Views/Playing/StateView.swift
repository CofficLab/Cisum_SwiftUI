import SwiftUI

struct StateView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var databaseManager: DBManager
    
    private var audio: AudioModel { audioManager.audio }
    private var isCached: Bool { audio.isCached }
    private var next: AudioModel { audioManager.playlist.getNext() }
    
    var body: some View {
        HStack(spacing: 2) {
//            Text(isDownloading ? "下载中" : "已下载")
//            Text(isCached ? "已缓存" : "未缓存")
            Text("下一首：\(next.title)")
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
