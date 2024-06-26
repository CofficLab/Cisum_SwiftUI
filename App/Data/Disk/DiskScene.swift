import Foundation
import SwiftUI

enum DiskScene: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case Baby
    case Music
    case KidsVideo
    
    var icon: some View {
        switch self {
        case .Baby:
            Image(systemName: "figure.and.child.holdinghands")
        case .Music:
            Image(systemName: "music.note.list")
        case .KidsVideo:
            Image(systemName: "video.circle")
        }
    }
    
    var folderName: String {
        switch self {
        case .Baby:
            "baby"
        case .Music:
            "music"
        case .KidsVideo:
            "kids_video"
        }
    }
    
    var title: String {
        switch self {
        case .Baby:
            "幼儿教育"
        case .Music:
            "听歌模式"
        case .KidsVideo:
            "幼儿视频"
        }
    }
    
    var description: String {
        switch self {
        case .Baby:
            "适用于小朋友听儿歌、故事等音频内容"
        case .Music:
            "作为歌曲仓库"
        case .KidsVideo:
            "适用于小朋友看动画片等场景"
        }
    }
    
    var card: some View {
        VStack {
            Text(title)
            
            Text(description).font(.footnote)
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("SceneView") {
    BootView {
        SceneView()
    }
}

#Preview("Scenes") {
    BootView {
        Scenes(selection: Binding.constant(.Baby), isPreseted: Binding.constant(false))
    }
}
