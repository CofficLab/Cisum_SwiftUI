import SwiftUI

struct DBTile: View {
    var asset: PlayAsset
    var dragging: Bool = false
    var trailing: String = ""
    var isFolder: Bool = false
    var level: Int = 0

    @State var deleting: Bool = false
    @State var selected: Bool = false
    @State var collapsed: Bool = false
    @State var indicatorHovered: Bool = false
    @State var hovered: Bool = false
    
    init(_ asset: PlayAsset) {
        self.asset = asset
    }

    var body: some View {
        MenuTile(
            title: asset.title,
            deleting: $deleting,
            selected: $selected,
            collapsed: $collapsed
        )
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}
