import Foundation

enum Menu {
    case Image
    
    var title: String {
        switch self {
        case .Image:
            "图片相关"
        }
    }
}
