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
        guard !data.isEmpty, maxValue.isFinite, maxValue > 0 else { return path }

        let stepX = rect.width / CGFloat(max(data.count - 1, 1))
        let height = rect.height

        path.move(to: CGPoint(x: 0, y: height))

        for (i, value) in data.enumerated() {
            let x = CGFloat(i) * stepX
            let normalizedValue = Self.normalizedValue(value, maxValue: maxValue)
            let y = height - CGFloat(normalizedValue) * height
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: CGFloat(data.count - 1) * stepX, y: height))
        path.closeSubpath()

        return path
    }

    private static func normalizedValue(_ value: Double, maxValue: Double) -> Double {
        guard value.isFinite else { return 0 }
        return min(max(value / maxValue, 0), 1)
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
        guard !data.isEmpty, maxValue.isFinite, maxValue > 0 else { return path }

        let stepX = rect.width / CGFloat(max(data.count - 1, 1))
        let height = rect.height

        for (i, value) in data.enumerated() {
            let x = CGFloat(i) * stepX
            let normalizedValue = Self.normalizedValue(value, maxValue: maxValue)
            let y = height - CGFloat(normalizedValue) * height
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }

    private static func normalizedValue(_ value: Double, maxValue: Double) -> Double {
        guard value.isFinite else { return 0 }
        return min(max(value / maxValue, 0), 1)
    }
}
