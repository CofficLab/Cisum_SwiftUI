import SwiftUI

// MARK: - Custom Mask Shapes

/// 心形
struct HeartShape: InsettableShape {
    func inset(by amount: CGFloat) -> some InsettableShape {
        HeartShape()
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: width * 0.5, y: height * 0.15))
        path.addCurve(
            to: CGPoint(x: width * 0.85, y: height * 0.05),
            control1: CGPoint(x: width * 0.65, y: height * 0.0),
            control2: CGPoint(x: width * 0.75, y: height * 0.0)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.35),
            control1: CGPoint(x: width * 0.95, y: height * 0.05),
            control2: CGPoint(x: width * 0.7, y: height * 0.2)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.5),
            control1: CGPoint(x: width * 0.6, y: height * 0.4),
            control2: CGPoint(x: width * 0.6, y: height * 0.45)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.2, y: height * 0.4),
            control1: CGPoint(x: width * 0.35, y: height * 0.55),
            control2: CGPoint(x: width * 0.25, y: height * 0.5)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.15, y: height * 0.05),
            control1: CGPoint(x: width * 0.15, y: height * 0.3),
            control2: CGPoint(x: width * 0.05, y: height * 0.15)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.15),
            control1: CGPoint(x: width * 0.15, y: height * 0.0),
            control2: CGPoint(x: width * 0.35, y: height * 0.0)
        )
        return path
    }
}

/// 六边形
struct HexagonShape: InsettableShape {
    var isVertical: Bool = true

    func inset(by amount: CGFloat) -> some InsettableShape {
        HexagonShape(isVertical: isVertical)
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        if isVertical {
            // 垂直六边形（上下两个平边）
            path.move(to: CGPoint(x: width * 0.25, y: 0))
            path.addLine(to: CGPoint(x: width * 0.75, y: 0))
            path.addLine(to: CGPoint(x: width, y: height * 0.5))
            path.addLine(to: CGPoint(x: width * 0.75, y: height))
            path.addLine(to: CGPoint(x: width * 0.25, y: height))
            path.addLine(to: CGPoint(x: 0, y: height * 0.5))
            path.closeSubpath()
        } else {
            // 水平六边形（左右两个平边）
            path.move(to: CGPoint(x: 0, y: height * 0.25))
            path.addLine(to: CGPoint(x: width * 0.5, y: 0))
            path.addLine(to: CGPoint(x: width, y: height * 0.25))
            path.addLine(to: CGPoint(x: width, y: height * 0.75))
            path.addLine(to: CGPoint(x: width * 0.5, y: height))
            path.addLine(to: CGPoint(x: 0, y: height * 0.75))
            path.closeSubpath()
        }
        return path
    }
}

/// 正多边形
struct RegularPolygonShape: InsettableShape {
    var sides: Int

    func inset(by amount: CGFloat) -> some InsettableShape {
        RegularPolygonShape(sides: sides)
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let center = CGPoint(x: width / 2, y: height / 2)
        let radius = min(width, height) / 2

        for i in 0..<sides {
            let angle = Double(i) * 2 * .pi / Double(sides) - .pi / 2
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

/// 菱形
struct DiamondShape: InsettableShape {
    func inset(by amount: CGFloat) -> some InsettableShape {
        DiamondShape()
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let center = CGPoint(x: width / 2, y: height / 2)

        path.move(to: CGPoint(x: center.x, y: 0))
        path.addLine(to: CGPoint(x: width, y: center.y))
        path.addLine(to: CGPoint(x: center.x, y: height))
        path.addLine(to: CGPoint(x: 0, y: center.y))
        path.closeSubpath()
        return path
    }
}

/// 星形
struct StarShape: InsettableShape {
    var points: Int = 5
    var inset: CGFloat = 0.4

    func inset(by amount: CGFloat) -> some InsettableShape {
        StarShape(points: points, inset: inset)
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let center = CGPoint(x: width / 2, y: height / 2)
        let outerRadius = min(width, height) / 2
        let innerRadius = outerRadius * inset

        var angle: Double = -.pi / 2
        let angleStep = .pi / Double(points)

        for i in 0..<points * 2 {
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }

            angle += angleStep
        }
        path.closeSubpath()
        return path
    }
}

/// 三角形
struct TriangleShape: InsettableShape {
    enum Direction {
        case up, down, left, right
    }

    var direction: Direction = .up

    func inset(by amount: CGFloat) -> some InsettableShape {
        TriangleShape(direction: direction)
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        switch direction {
        case .up:
            path.move(to: CGPoint(x: width / 2, y: 0))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
        case .down:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width / 2, y: height))
        case .left:
            path.move(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height / 2))
        case .right:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: width, y: height / 2))
            path.addLine(to: CGPoint(x: 0, y: height))
        }
        path.closeSubpath()
        return path
    }
}
