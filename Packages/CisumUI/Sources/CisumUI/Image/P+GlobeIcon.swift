import SwiftUI

#if DEBUG
/// 地球图标预览
struct GlobeIconPreviews: View {
    var body: some View {
        VStack(spacing: 30) {
            IconPreviewHelper(title: "Globe Icon") {
                Image.makeGlobeIcon()
            }

            IconPreviewHelper(title: "Globe Icon (Custom)") {
                Image.makeGlobeIcon(
                    useDefaultBackground: false,
                    borderColor: .purple
                )
            }
        }
    }
}

#Preview {
    GlobeIconPreviews()
}
#endif
