import SwiftUI

struct LayoutPreview: View {
    var width: CGFloat? = 0

    init(_ width: CGFloat? = nil) {
        self.width = width
    }

    var body: some View {
        if let width = width {
            makeItem(width: AppConfig.minWidth + width)
        } else {
            TabView(content: {
                ForEach([
                    0,
                    100,
//                    200,
//                    300
                ], id: \.self) { v in
                    makeItem(width: AppConfig.minWidth)
                        .id("\(v)")
                        .tabItem { Label("\(v)", systemImage: "apple") }
                }
            })
        }
    }

    func makeItem(width: CGFloat = 500) -> some View {
        let variables: [CGFloat] = [
            0,
//            100,
//            200,
//            300,
//            400, 
//            500,
//            600,
//            700, 
//            800,
//            900,
//            1000,
        ]

        return ScrollView {
            Spacer(minLength: 20)
            ForEach(variables, id: \.self) { v in
                RootView {
                    ContentView()
                }
                .frame(width: width)
                .frame(height: AppConfig.minHeight + v)
                Spacer(minLength: 30)
                Divider()
            }

            Spacer()
        }
        .modelContainer(AppConfig.getContainer())
        .frame(minWidth: width)
        .frame(minHeight: AppConfig.minHeight)
        .frame(height: 800)
        .background(BackgroundView.type2)
    }
}

#Preview("Layout") {
    LayoutPreview()
}

#Preview("100") {
    LayoutPreview(100)
}

#Preview("200") {
    LayoutPreview(200)
}

#Preview("300") {
    LayoutPreview(300)
}
