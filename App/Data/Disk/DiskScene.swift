import Foundation
import SwiftUI

enum DiskScene: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case Music
    case AudioBook
    case KidsAudio
    case KidsVideo
    
    var iconName: String {
        switch self {
        case .KidsAudio:
            "figure.and.child.holdinghands"
        case .Music:
            "music.note.list"
        case .AudioBook:
            "books.vertical.circle.fill"
        }
    }
    
    var icon: some View {
        switch self {
        case .KidsAudio:
            Image(systemName: "figure.and.child.holdinghands")
        case .Music:
            Image(systemName: "music.note.list")
        case .KidsVideo:
            Image(systemName: "video.circle")
        case .AudioBook:
            Image(systemName: "books.vertical.circle.fill")
        }
    }
    
    var folderName: String {
        switch self {
        case .KidsAudio:
            "kids_audio"
        case .Music:
            "music"
        case .KidsVideo:
            "kids_video"
        case .AudioBook:
            "audio_book"
        }
    }
    
    var title: String {
        switch self {
        case .KidsAudio:
            "青少年音频模式"
        case .Music:
            "听歌模式"
        case .KidsVideo:
            "青少年视频模式"
        case .AudioBook:
            "有声书模式"
        }
    }
    
    var description: String {
        switch self {
        case .KidsAudio:
            "适用于青少年听儿歌、故事等音频内容"
        case .Music:
            "作为歌曲仓库"
        case .KidsVideo:
            "适用于青少年看动画片等场景"
        case .AudioBook:
            "适用于听有声书的场景"
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
        Scenes(selection: Binding.constant(.KidsAudio), isPreseted: Binding.constant(false))
    }
}
