import Foundation

enum AppScene: CaseIterable, Identifiable {
    var id: Self { self }
    
    case Baby
    case Music
    
    var name: String {
        switch self {
        case .Baby:
            "幼儿教育"
        case .Music:
            "听歌模式"
        }
    }
}
