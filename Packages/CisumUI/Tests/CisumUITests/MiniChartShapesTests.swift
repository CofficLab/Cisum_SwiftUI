import SwiftUI
import Testing
@testable import CisumUI

struct MiniChartShapesTests {
    private let rect = CGRect(x: 0, y: 0, width: 100, height: 50)

    // MARK: - MiniGraphArea

    @Test
    @MainActor
    func areaPathIsEmptyForEmptyData() {
        let shape = MiniGraphArea(data: [], maxValue: 1)

        #expect(shape.path(in: rect).isEmpty)
    }

    @Test
    @MainActor
    func areaPathIsEmptyForNonPositiveMaxValue() {
        let zeroMax = MiniGraphArea(data: [0.5, 1.0], maxValue: 0)
        let negativeMax = MiniGraphArea(data: [0.5, 1.0], maxValue: -1)
        let infiniteMax = MiniGraphArea(data: [0.5, 1.0], maxValue: .infinity)

        #expect(zeroMax.path(in: rect).isEmpty)
        #expect(negativeMax.path(in: rect).isEmpty)
        #expect(infiniteMax.path(in: rect).isEmpty)
    }

    @Test
    @MainActor
    func areaPathSpansFullRectAndIsClosed() {
        let shape = MiniGraphArea(data: [0, 1.0], maxValue: 1)

        let path = shape.path(in: rect)
        let bounds = path.boundingRect

        #expect(!path.isEmpty)
        #expect(bounds.minX == 0)
        #expect(bounds.maxX == rect.width)
        #expect(bounds.minY == 0)
        #expect(bounds.maxY == rect.height)
    }

    @Test
    @MainActor
    func areaPathClampsInvalidDataPointsWithinRect() {
        let shape = MiniGraphArea(data: [.nan, -1, 0.5, .infinity, 2], maxValue: 1)

        let path = shape.path(in: rect)
        let bounds = path.boundingRect

        #expect(!path.isEmpty)
        #expect(bounds.minY >= 0)
        #expect(bounds.maxY <= rect.height)
    }

    // MARK: - MiniGraphLine

    @Test
    @MainActor
    func linePathIsEmptyForEmptyData() {
        let shape = MiniGraphLine(data: [], maxValue: 1)

        #expect(shape.path(in: rect).isEmpty)
    }

    @Test
    @MainActor
    func linePathIsEmptyForNonPositiveMaxValue() {
        let shape = MiniGraphLine(data: [0.25, 0.75], maxValue: 0)
        let infiniteMax = MiniGraphLine(data: [0.25, 0.75], maxValue: .infinity)

        #expect(shape.path(in: rect).isEmpty)
        #expect(infiniteMax.path(in: rect).isEmpty)
    }

    @Test
    @MainActor
    func linePathFollowsDataPointsWithinRect() {
        let shape = MiniGraphLine(data: [0, 0.5, 1.0], maxValue: 1)

        let path = shape.path(in: rect)
        let bounds = path.boundingRect

        #expect(!path.isEmpty)
        #expect(bounds.minX == 0)
        #expect(bounds.maxX == rect.width)
        #expect(bounds.minY == 0)
        #expect(bounds.maxY == rect.height)
    }

    @Test
    @MainActor
    func linePathClampsInvalidDataPointsWithinRect() {
        let shape = MiniGraphLine(data: [.nan, -1, 0.5, .infinity, 2], maxValue: 1)

        let path = shape.path(in: rect)
        let bounds = path.boundingRect

        #expect(!path.isEmpty)
        #expect(bounds.minY >= 0)
        #expect(bounds.maxY <= rect.height)
    }

    @Test
    @MainActor
    func lineAndAreaPathsDifferForSameInput() {
        let data: [Double] = [0.2, 0.6, 0.4]
        let area = MiniGraphArea(data: data, maxValue: 1).path(in: rect)
        let line = MiniGraphLine(data: data, maxValue: 1).path(in: rect)

        #expect(!area.isEmpty)
        #expect(!line.isEmpty)
        #expect(area.boundingRect.height >= line.boundingRect.height)
    }
}
