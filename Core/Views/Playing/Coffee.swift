import SwiftUI
import MagicKit
import MagicUI

struct Coffee: View {
    @State private var rotationAngle: Double = 0
    
    var rotate = true

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack {
                    // 盘子
                    Circle()
                        .stroke(lineWidth: 270)
                        .frame(width: 1200, height: 1200)
                        .foregroundColor(.white.opacity(0.6))
                        .scaleEffect(0.8)
                    
                    // 把手
                    RoundedRectangle(cornerRadius: 0)
                        .frame(width: 120, height: 110)
                        .foregroundColor(.brown)
                        .rotationEffect(.degrees(90))
                        .offset(x: 430, y: 0)
                    RoundedRectangle(cornerRadius: 70, style: .continuous)
                        .frame(width: 120, height: 130)
                        .foregroundColor(.brown)
                        .rotationEffect(.degrees(90))
                        .offset(x: 470, y: 0)

                    // 咖啡杯边框
                    Capsule()
                        .stroke(Color.brown, lineWidth: 20)
                        .frame(width: 750, height: 750)

                    // 咖啡
                    Circle()
                        .frame(width: 630, height: 630)
                        .overlay(content: {
                            ZStack(content: {
                                Color.black.opacity(0.8)
                                Color.brown.opacity(0.5)
                            }).clipShape(Circle())
                        })

                    bubble(100, 100)
                    bubble(-100, 100)
                    bubble(100, -100)
                    bubble(-100, -100)
                    bubble(0, 0, size: 50)
                }
                .frame(maxWidth: min(geo.size.width, geo.size.height), maxHeight: min(geo.size.width, geo.size.height))
                .scaleEffect(min(geo.size.width, geo.size.height) / 1500)
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
            .fill(Color.white.opacity(0.1))
            .frame(width: size, height: size)
            .offset(x: x, y: y)
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
        .background(MagicBackground.aurora)
}

#Preview {
    VStack(spacing: 0) {
        Coffee()
//        Coffee(rotate: true)
    }.frame(width: 300, height: 100)
        .background(MagicBackground.aurora)
}

#Preview {
    HStack {
        Coffee()
        Coffee(rotate: true)
    }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MagicBackground.aurora)
}
