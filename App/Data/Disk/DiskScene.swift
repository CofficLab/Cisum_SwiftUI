import Foundation

enum DiskScene: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case Baby
    case Music
    case KidsVideo
    
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
}
