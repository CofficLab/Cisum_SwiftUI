import SwiftUI
import Foundation

class AppAudio: SuperLayout {    
    var id: String = "Audio"
    
    var layout: any View {
        AudioLayout()
    }
    
    var poster: any View {
        AudioPoster()
    }
    
    var title = "歌曲模式"
    var description: String = "作为歌曲仓库，只关注文件，文件夹将被忽略"
}
