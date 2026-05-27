import SwiftUI

extension MagicBackground {
    static public var candyLand: some View {
        ZStack {
            // 糖果色渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FF9A9E").opacity(0.7),  // 粉红色
                    Color(hex: "FAD0C4").opacity(0.6)   // 浅粉色
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 棒棒糖图案
            GeometryReader { geometry in
                ForEach(0..<5) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FF6B6B").opacity(0.4),
                                    Color(hex: "FFB8B8").opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .offset(
                            x: CGFloat(index) * geometry.size.width / 4,
                            y: sin(CGFloat(index) * .pi / 2) * 30
                        )
                        .blur(radius: 5)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var crayonBox: some View {
        ZStack {
            // 彩色铅笔背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FFD700").opacity(0.5),  // 金黄色
                    Color(hex: "98FB98").opacity(0.5),  // 浅绿色
                    Color(hex: "87CEEB").opacity(0.5)   // 天蓝色
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 铅笔线条效果
            GeometryReader { geometry in
                ForEach(0..<8) { index in
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 3, height: geometry.size.height * 0.7)
                        .rotationEffect(.degrees(Double(index) * 5))
                        .offset(x: CGFloat(index) * geometry.size.width / 8)
                        .blur(radius: 2)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var toyBlocks: some View {
        ZStack {
            // 积木色彩背景
            Color(hex: "F0F8FF").opacity(0.8)  // 爱丽丝蓝
            
            // 积木方块效果
            GeometryReader { geometry in
                ForEach(0..<12) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            Color(
                                hex: ["FF6B6B", "4ECDC4", "FFD93D", "6C5CE7"][index % 4]
                            ).opacity(0.3)
                        )
                        .frame(width: 60, height: 60)
                        .position(
                            x: CGFloat(index % 4) * geometry.size.width / 3,
                            y: CGFloat(index / 4) * geometry.size.height / 3
                        )
                        .rotationEffect(.degrees(Double.random(in: -5...5)))
                        .shadow(radius: 2)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var balloonParty: some View {
        ZStack {
            // 天空背景
            Color(hex: "E0FFFF").opacity(0.8)  // 淡青色
            
            // 气球效果
            GeometryReader { geometry in
                ForEach(0..<8) { index in
                    Circle()
                        .fill(
                            Color(
                                hex: ["FF9999", "99FF99", "9999FF", "FFFF99"][index % 4]
                            ).opacity(0.4)
                        )
                        .frame(width: CGFloat.random(in: 40...80))
                        .position(
                            x: CGFloat(index) * geometry.size.width / 8,
                            y: geometry.size.height * CGFloat.random(in: 0.3...0.7)
                        )
                        .blur(radius: 3)
                }
                
                // 气球线
                ForEach(0..<8) { index in
                    Path { path in
                        path.move(to: CGPoint(
                            x: CGFloat(index) * geometry.size.width / 8,
                            y: geometry.size.height * 0.8
                        ))
                        path.addCurve(
                            to: CGPoint(
                                x: CGFloat(index) * geometry.size.width / 8,
                                y: geometry.size.height * CGFloat.random(in: 0.3...0.7)
                            ),
                            control1: CGPoint(
                                x: CGFloat(index) * geometry.size.width / 8 - 20,
                                y: geometry.size.height * 0.6
                            ),
                            control2: CGPoint(
                                x: CGFloat(index) * geometry.size.width / 8 + 20,
                                y: geometry.size.height * 0.4
                            )
                        )
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var paperPlanes: some View {
        ZStack {
            // 蓝天背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "87CEEB").opacity(0.7),  // 天蓝色
                    Color(hex: "E0FFFF").opacity(0.6)   // 淡青色
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 纸飞机效果
            GeometryReader { geometry in
                ForEach(0..<6) { index in
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 20, y: 10))
                        path.addLine(to: CGPoint(x: 10, y: 20))
                        path.addLine(to: CGPoint(x: 0, y: 0))
                    }
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 20, height: 20)
                    .position(
                        x: CGFloat(index) * geometry.size.width / 5,
                        y: sin(CGFloat(index) * .pi / 3) * 50 + geometry.size.height / 2
                    )
                    .rotationEffect(.degrees(45))
                    .shadow(radius: 2)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

#if DEBUG
#Preview("Childhood Themes") {
    TabView {
        // 童年主题
            ScrollView {
                VStack(spacing: 20) {
                    Text("童年主题")
                        .font(.headline)
                        .padding(.top)
                    
                    Group {
                        BackgroundPreviewItem(
                            background: AnyView(MagicBackground.candyLand),
                            title: "Candy Land",
                            textColor: .primary
                        )
                        
                        BackgroundPreviewItem(
                            background: AnyView(MagicBackground.crayonBox),
                            title: "Crayon Box",
                            textColor: .primary
                        )
                        
                        BackgroundPreviewItem(
                            background: AnyView(MagicBackground.toyBlocks),
                            title: "Toy Blocks",
                            textColor: .primary
                        )
                        
                        BackgroundPreviewItem(
                            background: AnyView(MagicBackground.balloonParty),
                            title: "Balloon Party",
                            textColor: .primary
                        )
                        
                        BackgroundPreviewItem(
                            background: AnyView(MagicBackground.paperPlanes),
                            title: "Paper Planes",
                            textColor: .primary
                        )
                    }
                }
                .padding()
            }
        
        .tabItem {
            Image(systemName: "face.smiling.fill")
            Text("童年")
        }
    }
}
#endif

// MARK: - View Extensions

