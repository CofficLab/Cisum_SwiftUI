import SwiftUI

struct PlayAsset {
    var url: URL
    
    var title: String { url.lastPathComponent }
}

#Preview {
    AppPreview()
}
