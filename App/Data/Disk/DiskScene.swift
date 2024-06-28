import Foundation
import SwiftUI

enum DiskScene: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case Music
    case AudiosBook
    case AudiosKids
    case VideosKids
    
    var iconName: String {
        switch self {
        case .AudiosKids:
            "figure.and.child.holdinghands"
        case .Music:
            "music.note.list"
        case .AudiosBook:
            "books.vertical.circle.fill"
        case .VideosKids:
            "video.circle"
        }
    }
    
    var icon: some View {
        switch self {
        case .AudiosKids:
            Image(systemName: "figure.and.child.holdinghands")
        case .Music:
            Image(systemName: "music.note.list")
        case .VideosKids:
            Image(systemName: "video.circle")
        case .AudiosBook:
            Image(systemName: "books.vertical.circle")
        }
    }
    
    var folderName: String {
        switch self {
        case .Music:
            "audios"
        case .AudiosKids:
            "audios_kids"
        case .AudiosBook:
            "audios_book"
        case .VideosKids:
            "videos_kids"
        }
    }
    
    var title: String {
        switch self {
        case .AudiosKids:
            "青少年音频模式"
        case .Music:
            "听歌模式"
        case .VideosKids:
            "青少年视频模式"
        case .AudiosBook:
            "有声书模式"
        }
    }
    
    var description: String {
        switch self {
        case .AudiosKids:
            "适用于青少年听儿歌、故事等音频内容"
        case .Music:
            "作为歌曲仓库，只关注文件，文件夹将被忽略"
        case .VideosKids:
            "适用于青少年看动画片等场景"
        case .AudiosBook:
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
        Scenes(selection: Binding.constant(.AudiosKids), isPreseted: Binding.constant(false))
    }
}
