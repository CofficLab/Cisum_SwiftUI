import SwiftUI


struct BtnToggleCopying: View {
    @EnvironmentObject var app: AppProvider
    
    @Binding var isActive: Bool
    
    var autoResize = false

    var body: some View {
        ControlButton(
            title: "仓库",
            image: "list.bullet",
            dynamicSize: autoResize,
            onTap: {
                isActive.toggle()
        })
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}


