import Foundation
import SwiftData
import SwiftUI

enum DiskScene: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case Music
    case AudiosBook
    case AudiosKids
    case Videos
    case VideosKids
    
    var available: Bool {
        switch self {
        case .Music,.AudiosBook:
            true
        case .Videos:
            true
        case .AudiosKids,.VideosKids:
            false
        }
    }
    
    var iconName: String {
        switch self {
        case .AudiosKids:
            "figure.and.child.holdinghands"
        case .Music:
            "music.note.list"
        case .AudiosBook:
            "books.vertical"
        case .VideosKids:
            "teddybear"
        case .Videos:
            "video"
        }
    }
    
    var icon: some View {
        Image(systemName: iconName)
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
        case .Videos:
            "videos"
        }
    }
    
    var title: String {
        switch self {
        case .AudiosKids:
            "青少年音频模式"
        case .Music:
            "歌曲模式"
        case .VideosKids:
            "青少年视频模式"
        case .AudiosBook:
            "有声书模式"
        case .Videos:
            "视频模式"
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
        case .Videos:
            "适用于看视频的场景"
        }
    }
    
    var prepareCount: Int {
        switch self {
        case .Music:
            6
        case .AudiosBook:
            6
        case .AudiosKids:
            6
        case .Videos:
            1
        case .VideosKids:
            1
        }
    }
    
//    var card: some View {
//        VStack {
//            HStack {
//                self.icon
//                Text(title)
//            }
//            .font(.title)
//            .padding()
//            
//            Text(description)
//            
//            GroupBox {
//                hero
//            }.padding()
//        }
//    }
    
//    var hero: some View {
//        ZStack {
//            switch self {
//            case .Music:
//                AudioScene()
//            case .AudiosBook:
//                BookScene()
//            case .AudiosKids:
//                BookScene()
//            case .Videos:
//                BookScene()
//            case .VideosKids:
//                BookScene()
//            }
//        }
//    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Scenes") {
    BootView {
        Posters(isPresented: .constant(false))
            .background(.background)
    }
    .frame(height: 800)
}
