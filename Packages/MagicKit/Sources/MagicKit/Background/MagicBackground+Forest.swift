import SwiftUI

extension MagicBackground {
    static public var mysticalForest: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "2D5A27").opacity(0.8),  // 深森林绿
                    Color(hex: "1B4D3E").opacity(0.8)   // 墨绿
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 光束效果
            GeometryReader { geometry in
                ForEach(0..<5) { _ in
                    Path { path in
                        let startX = CGFloat.random(in: 0...geometry.size.width)
                        path.move(to: CGPoint(x: startX, y: 0))
                        path.addLine(to: CGPoint(x: startX + 50, y: geometry.size.height))
                    }
                    .stroke(Color.white.opacity(0.1), lineWidth: 50)
                    .blur(radius: 30)
                }
            }
            
            // 雾气效果
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.1),
                    Color.clear
                ]),
                center: .top,
                startRadius: 100,
                endRadius: 400
            )
            .blur(radius: 20)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var enchantedGrove: some View {
        ZStack {
            // 基础层
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "3B7A57").opacity(0.7),  // 翡翠绿
                    Color(hex: "2F4F4F").opacity(0.7)   // 暗岩灰
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 光斑效果
            GeometryReader { geometry in
                ForEach(0..<20) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: CGFloat.random(in: 20...60))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .blur(radius: 15)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    static public var deepForest: some View {
        ZStack {
            // 基础层
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1B4D3E").opacity(0.8),  // 深绿
                    Color(hex: "0B2B1F").opacity(0.9)   // 暗绿
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 树叶纹理
            GeometryReader { geometry in
                ForEach(0..<30) { _ in
                    Circle()
                        .fill(Color(hex: "2D5A27").opacity(0.1))
                        .frame(width: CGFloat.random(in: 30...80))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .blur(radius: 10)
                }
                
                // 萤火虫效果
                ForEach(0..<15) { _ in
                    Circle()
                        .fill(Color(hex: "FFFF00").opacity(0.3))
                        .frame(width: CGFloat.random(in: 2...4))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .blur(radius: 2)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

#if DEBUG
#Preview("Forest Themes") {
    TabView {
        // 森林主题
            ScrollView {
                VStack(spacing: 20) {
                    Text("森林主题")
                        .font(.headline)
                        .padding(.top)
                    
                    Group {
                        BackgroundPreviewItem(
                            background: AnyView(MagicBackground.mysticalForest),
                            title: "Mystical Forest"
                        )
                        
                        BackgroundPreviewItem(
                            background: AnyView(MagicBackground.enchantedGrove),
                            title: "Enchanted Grove"
                        )
                        
                        BackgroundPreviewItem(
                            background: AnyView(MagicBackground.deepForest),
                            title: "Deep Forest"
                        )
                    }
                }
                .padding()
            }
        
        .tabItem {
            Image(systemName: "leaf.fill")
            Text("森林")
        }
    }
}
#endif

// MARK: - View Extensions

