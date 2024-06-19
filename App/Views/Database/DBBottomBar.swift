import SwiftUI

struct DBBottomBar: View {
    @Binding var treeView: Bool
    
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "list.bullet")
                .onTapGesture {
                    self.treeView = false
                }
            Image(systemName: "rectangle.3.group.fill")
                .onTapGesture {
                    self.treeView = true
                }
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 3)
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
