import SwiftUI
import Foundation

class VideoApp: SuperLayout {
    var id = "Video"
    
    var layout: any View {
        VideoLayout()
    }
    
    var poster: any View {
        Text("Video")
    }

    var title: String {
        "视频模式"
    }

    var description: String {
        "适用于看视频的场景"
    }
    
    func getDisk() -> (any Disk)? {
        DiskiCloud.make("videos")
    }
}
