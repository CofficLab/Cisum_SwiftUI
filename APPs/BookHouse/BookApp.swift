import SwiftUI
import Foundation

class BookApp: SuperLayout {
    var id: String = "Book"
    
    var layout: any View {
        BookLayout()
    }
    
    var poster: any View {
        BookPoster()
    }

    var title: String {
        "有声书模式"
    }

    var description: String {
        "适用于听有声书的场景"
    }
}
