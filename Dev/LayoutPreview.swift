import SwiftUI

struct LayoutPreview: View {
    var width: CGFloat = 500
    var height: CGFloat = 500
    
    var body: some View {
        let variables: [CGFloat] = [
            0, 100, 200, 300,
            400, 500, 600, 700, 800, 900, 1000
        ]
        
        return VStack {
            ForEach(variables, id: \.self) { v in
                RootView {
                    HomeView()
                }
                .frame(width: width)
                .frame(height: height + v)
                
                Spacer(minLength: 30)
                Divider()
            }
            
            Spacer()
        }
        .frame(width: width)
        .background(BackgroundView.forest)
        .modelContainer(AppConfig.getContainer())
    }
}

#Preview("1") {
    LayoutPreview(width: AppConfig.minWidth, height: AppConfig.minHeight)
}

#Preview("2") {
    LayoutPreview(width: AppConfig.minWidth + 100, height: AppConfig.minHeight)
}

#Preview("3") {
    LayoutPreview(width: AppConfig.minWidth+200, height: AppConfig.minHeight)
}

#Preview("4") {
    LayoutPreview(width: AppConfig.minWidth+300, height: AppConfig.minHeight)
}

