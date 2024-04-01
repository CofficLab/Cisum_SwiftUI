import SwiftUI

struct Coffee: View {
    @State private var rotationAngle: Double = 0

    var rotate = false
    var withBackground = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack {
                    // 盘子
                    Circle()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.white.opacity(0.6))
                        .scaleEffect(0.8)

                    // 把手
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 10, height: 40)
                        .foregroundColor(.gray.opacity(0.8))
                        .rotationEffect(.degrees(45))
                        .offset(x: 30, y: -25)

                    // 咖啡杯
                    Capsule()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(1))

                    // 咖啡
                    Circle()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.brown)
                }
                .frame(maxWidth: min(geo.size.width, geo.size.height), maxHeight: min(geo.size.width, geo.size.height))
                .scaleEffect(min(geo.size.width, geo.size.height) / 150)
                .background(background)
                .rotationEffect(.degrees(rotationAngle))
                .onTapGesture {
                    withAnimation {
                        rotationAngle += 30
                    }
                }
                .onAppear {
                    if rotate {
                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                            withAnimation {
                                rotationAngle += 0.3
                            }
                        }
                    }
            }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    var background: some View {
        ZStack {
            if withBackground {
                BackgroundView.type1.clipShape(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4)))
            } else {
                Color.clear
            }
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}

#Preview {
    VStack(spacing: 0) {
        Coffee()
//        Coffee(rotate: true)
    }.frame(width: 400, height: 400)
        .background(BackgroundView.type1)
}

#Preview {
    VStack(spacing: 0) {
        Coffee()
//        Coffee(rotate: true)
    }.frame(width: 300, height: 100)
        .background(BackgroundView.type1)
}

#Preview {
    HStack {
        Coffee()
        Coffee(rotate: true)
    }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundView.type1)
}
