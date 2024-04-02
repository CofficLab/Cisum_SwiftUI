import SwiftUI

struct StateView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    
    private var audio: Audio? { audioManager.audio }
//    private var next: Audio? { audioManager.list.getNext() }
    
    var body: some View {
        HStack(spacing: 2) {
//            Text(isDownloading ? "下载中" : "已下载")
//            Text(isCached ? "已缓存" : "未缓存")
//            if let n = next {
//                Text("下一首：\(n.title)")
//            } else {
//                Text("无下一首")
//            }
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
