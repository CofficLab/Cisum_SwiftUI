import SwiftUI
import Foundation

class AudioApp: SuperLayout {
    var id: String = "Audio"
    
    var iconName: String = "music.note.list"
    
    var icon: any View {
        Image(systemName: iconName)
    }
    
    var layout: any View {
        AudioLayout()
    }
    
    var poster: any View {
        AudioPoster()
    }
    
    var title = "歌曲模式"
    var description: String = "作为歌曲仓库，只关注文件，文件夹将被忽略"
    
    func getDisk() -> (any Disk)? {
        DiskiCloud.make("audios")
    }
}
