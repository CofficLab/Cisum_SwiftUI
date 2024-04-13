import SwiftUI

struct LayoutPreview: View {
    var body: some View {
        TabView(content: {
            makeItem(width: AppConfig.minWidth, height: AppConfig.minHeight)
                .tabItem { Label("0", systemImage: "apple") }
            makeItem(width: AppConfig.minWidth + 100, height: AppConfig.minHeight)
                .tabItem { Label("1", systemImage: "apple") }
            makeItem(width: AppConfig.minWidth + 200, height: AppConfig.minHeight)
                .tabItem { Label("2", systemImage: "apple") }
            makeItem(width: AppConfig.minWidth + 300, height: AppConfig.minHeight)
                .tabItem { Label("3", systemImage: "apple") }
            makeItem(width: AppConfig.minWidth + 400, height: AppConfig.minHeight)
                .tabItem { Label("4", systemImage: "apple") }
            makeItem(width: AppConfig.minWidth + 500, height: AppConfig.minHeight)
                .tabItem { Label("5", systemImage: "apple") }
            makeItem(width: AppConfig.minWidth + 600, height: AppConfig.minHeight)
                .tabItem { Label("6", systemImage: "apple") }
            makeItem(width: AppConfig.minWidth + 700, height: AppConfig.minHeight)
                .tabItem { Label("7", systemImage: "apple") }
            makeItem(width: AppConfig.minWidth + 800, height: AppConfig.minHeight)
                .tabItem { Label("8", systemImage: "apple") }
        })
    }
    
    func makeItem(width: CGFloat = 500, height: CGFloat = 500) -> some View {
        let variables: [CGFloat] = [
            0, 100, 200, 300,
            400, 500, 600, 700, 800, 900, 1000
        ]
        
        return ScrollView {
            Spacer(minLength: 20)
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
//        .frame(width: width)
        .frame(minHeight: AppConfig.minHeight)
        .frame(height: 800)
        .background(BackgroundView.forest)
        .modelContainer(AppConfig.getContainer())
    }
}

#Preview("Layout") {
    LayoutPreview()
}

