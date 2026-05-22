import SwiftUI

public struct MiniGraphArea: Shape {
    let data: [Double]
    let maxValue: Double

    public init(data: [Double], maxValue: Double) {
        self.data = data
        self.maxValue = maxValue
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        guard !data.isEmpty, maxValue > 0 else { return path }

        let stepX = rect.width / CGFloat(max(data.count - 1, 1))
        let height = rect.height

        path.move(to: CGPoint(x: 0, y: height))

        for (i, value) in data.enumerated() {
            let x = CGFloat(i) * stepX
            let y = height - CGFloat(value / maxValue) * height
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: CGFloat(data.count - 1) * stepX, y: height))
        path.closeSubpath()

        return path
    }
}

public struct MiniGraphLine: Shape {
    let data: [Double]
    let maxValue: Double

    public init(data: [Double], maxValue: Double) {
        self.data = data
        self.maxValue = maxValue
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        guard !data.isEmpty, maxValue > 0 else { return path }

        let stepX = rect.width / CGFloat(max(data.count - 1, 1))
        let height = rect.height

        for (i, value) in data.enumerated() {
            let x = CGFloat(i) * stepX
            let y = height - CGFloat(value / maxValue) * height
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }
}
