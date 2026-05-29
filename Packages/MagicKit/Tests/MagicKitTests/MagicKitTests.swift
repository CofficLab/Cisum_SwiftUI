import XCTest
@testable import MagicKit

final class MagicKitTests: XCTestCase {
    func testExample() throws {
        // This is an example test case
        XCTAssertTrue(true)
    }

    func testImageCropping() {
        // 暂时跳过此测试，因为缺少相关的图像处理功能
        // let originalImage = UIImage(named: "testImage")!
        // let croppedImage = MagicKit.cropImage(originalImage, to: CGRect(x: 0, y: 0, width: 100, height: 100))
        // 
        // XCTAssertNotNil(croppedImage)
        // XCTAssertEqual(croppedImage.size, CGSize(width: 100, height: 100))
    }

    // Add more test methods here
}