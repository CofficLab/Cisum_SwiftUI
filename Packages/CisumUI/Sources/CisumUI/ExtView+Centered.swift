import SwiftUI

extension View {
    /// 将视图居中显示在容器中
    /// 使用 ZStack 和 Spacer 实现水平和垂直居中布局
    public func magicCentered() -> some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    self
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Magic Centered - Text") {
        Text("Hello, World!")
            .font(.title)
            .foregroundColor(.blue)
            .magicCentered()
            .frame(width: 300, height: 200)
            .background(Color.gray.opacity(0.1))
    }

    #if DEBUG
    #Preview("Magic Centered - Button") {
        Button(action: {}) {
            Text("Click Me")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
        }
        .magicCentered()
        .frame(width: 300, height: 200)
        .background(Color.gray.opacity(0.1))
    }
    #endif

    #if DEBUG
    #Preview("Magic Centered - Image") {
        Image(systemName: "star.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .foregroundColor(.yellow)
            .magicCentered()
            .frame(width: 300, height: 200)
            .background(Color.gray.opacity(0.1))
    }
    #endif

    #if DEBUG
    #Preview("Magic Centered - VStack") {
        VStack(spacing: 20) {
            Text("Title")
                .font(.title)
            Text("Subtitle")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button("Action") {}
        }
        .magicCentered()
        .frame(width: 300, height: 400)
        .background(Color.gray.opacity(0.1))
    }
    #endif
#endif
