import SwiftUI

struct StateView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var databaseManager: DBManager
    @EnvironmentObject var playListManager: PlayListManager
    
    private var audio: AudioModel { audioManager.audio }
    private var isDownloading: Bool { audio.isDownloading }
    private var isCached: Bool { audio.isCached }
    
    var body: some View {
        HStack(spacing: 2) {
            Text(isDownloading ? "下载中" : "已下载")
            Text(isCached ? "已缓存" : "未缓存")
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
