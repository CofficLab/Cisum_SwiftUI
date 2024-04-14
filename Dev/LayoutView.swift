import SwiftUI

struct LayoutView: View {
    var width: CGFloat? = 0

    init(_ width: CGFloat? = nil) {
        self.width = width ?? nil
    }

    var body: some View {
        VStack {
            if let width = width {
                makeItem(width: AppConfig.minWidth + width)
            } else {
                TabView(content: {
                    ForEach([
                        0,
                        100,
                        200,
                        300
                    ], id: \.self) { v in
                        makeItem(width: AppConfig.minWidth + v)
                            .id("\(v)")
                            .tabItem { Label("\(Int(v))", systemImage: "apple") }
                    }
                })
            }
        }
    }

    func makeItem(width: CGFloat = 500) -> some View {
        let variables: [CGFloat] = [
            0,
            100,
            200,
            300,
            400, 
            500,
            600,
            700, 
            800,
            900,
            1000,
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
    LayoutView()
}

#Preview("100") {
    LayoutView(100)
}

#Preview("200") {
    LayoutView(200)
}

#Preview("300") {
    LayoutView(300)
}
