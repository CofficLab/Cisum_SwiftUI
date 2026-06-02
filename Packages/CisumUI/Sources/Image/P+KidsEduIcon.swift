import SwiftUI

#if DEBUG
/// 儿童教育图标预览
struct KidsEduIconPreviews: View {
    var body: some View {
        VStack(spacing: 30) {
            IconPreviewHelper(title: "Kids Edu Icon") {
                Image.makeKidsEduIcon()
            }

            IconPreviewHelper(title: "Kids Edu Icon (Custom)") {
                Image.makeKidsEduIcon(
                    useDefaultBackground: false,
                    borderColor: .purple
                )
            }
        }
    }
}

#Preview {
    KidsEduIconPreviews()
}
#endif
