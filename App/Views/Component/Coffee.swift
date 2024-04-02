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
                        .frame(width: 1500, height: 1500)
                        .foregroundColor(.white.opacity(0.6))
                        .scaleEffect(0.8)

                    // 把手
//                    RoundedRectangle(cornerRadius: 10)
//                        .frame(width: 100, height: 500)
//                        .foregroundColor(.gray.opacity(0.8))
//                        .rotationEffect(.degrees(90))
//                        .offset(x: 300, y: 0)

                    // 咖啡杯边框
                    Capsule()
                        .stroke(Color.cyan, lineWidth: 1)
                        .frame(width: 750, height: 750)
                    
                    // 咖啡杯
                    Capsule()
                        .frame(width: 750, height: 750)
                        .foregroundColor(.gray.opacity(1))

                    // 咖啡
                    Circle()
                        .frame(width: 630, height: 630)
                        .overlay(content: {
                            ZStack(content: {
                                Color.black.opacity(0.2)
                                Color.brown.opacity(0.5)
                            }).clipShape(Circle())
                        })
                    
                    bubble(100, 100)
                    bubble(-100, 100)
                    bubble(100, -100)
                    bubble(-100, -100)
                    bubble(0, 0, size: 110)
                }
                .frame(maxWidth: min(geo.size.width, geo.size.height), maxHeight: min(geo.size.width, geo.size.height))
                .scaleEffect(min(geo.size.width, geo.size.height) / 1500)
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
    
    func bubble(_ x: CGFloat, _ y: CGFloat, size: CGFloat = 160) -> some View {
        Circle()
            .frame(width: size, height: size)
            .overlay(content: {
                ZStack(content: {
                    Color.black.opacity(0.5)
                    Color.brown.opacity(0.2)
                }).clipShape(Circle())
            })
            .offset(x: x, y: y)
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
