import SwiftUI

struct DefaultCover: View {
    var withBackground: Bool = true
    var body: some View {
        ZStack {
            HStack {
                Image("Coffee")
                    .resizable()
                    .scaledToFit()
                    .background(background)
            }
        }
        .rotationEffect(.degrees(-90))
        
        .clipShape(withBackground ? RoundedRectangle(cornerSize: CGSize(
            width: 4,
            height: 4
        )) : RoundedRectangle(cornerSize: CGSize(
            width: 0,
            height: 0
        )))
    }
    
    var background: some View {
        ZStack {
            if withBackground {
                BackgroundView.type1
            } else {
                Color.clear
            }
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}

#Preview {
    VStack {
        DefaultCover(withBackground: true)
        DefaultCover(withBackground: false)
    }
}
