import SwiftUI

struct DefaultCover: View {
    @State private var rotationAngle: Double = 0
    var withBackground: Bool = true
    var rotate: Bool = false
    var body: some View {
        ZStack {
            HStack {
                Image("Coffee")
                    .resizable()
                    .scaledToFit()
                    .background(background)
            }.scaleEffect(1.25)
        }
        .rotationEffect(.degrees(-90))

        .clipShape(withBackground ? RoundedRectangle(cornerSize: CGSize(
            width: 4,
            height: 4
        )) : RoundedRectangle(cornerSize: CGSize(
            width: 0,
            height: 0
        )))

        .rotationEffect(.degrees(rotationAngle))
        .onAppear { 
            if rotate {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    withAnimation {
                        rotationAngle += 0.3
                    }
                }
            }
        }
    }

    var background: some View {
        ZStack {
            if withBackground {
                BackgroundView.type2.opacity(0.7)
                Color.black.opacity(0.3)
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
