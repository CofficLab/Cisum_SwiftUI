import SwiftUI

struct LayoutPreview: View {
    var body: some View {
        RootView {
            TabView(content: {
//                ForEach([0, 100], id: \.self) { v in
                    makeItem(width: AppConfig.minWidth)
                    .id("0")
                        .tabItem { Label("1", systemImage: "apple") }
                makeItem(width: AppConfig.minWidth)
                    .id("100")
                    .tabItem { Label("100", systemImage: "apple") }
//                }
            })
        }
        .modelContainer(AppConfig.getContainer())
    }

    func makeItem(width: CGFloat = 500) -> some View {
        let variables: [CGFloat] = [
            0,
//            100,
//            200,
//            300,
//            400, 500, 600,
//            700, 800, 900,
//            1000
        ]

        return ScrollView {
            Spacer(minLength: 20)
            ForEach(variables, id: \.self) { v in
                HomeView()
                    .frame(width: width)
                    .frame(height: AppConfig.minHeight + v)
                Spacer(minLength: 30)
                Divider()
            }

            Spacer()
        }
//        .frame(minWidth: width)
//        .frame(minHeight: AppConfig.minHeight)
//        .frame(height: 600)
    }
}

#Preview("Layout") {
    LayoutPreview()
}
