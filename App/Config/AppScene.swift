import Foundation

enum AppScene: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case Baby
    case Music
    
    var folderName: String {
        switch self {
        case .Baby:
            "baby"
        case .Music:
            "music"
        }
    }
    
    var title: String {
        switch self {
        case .Baby:
            "幼儿教育"
        case .Music:
            "听歌模式"
        }
    }
}
