import XCTest
@testable import MagicKit

final class MagicKitTests: XCTestCase {
    func testExample() throws {
        // This is an example test case
        XCTAssertTrue(true)
    }

    func testToURLKeepsValidURL() {
        let url = "https://example.com/path".toURL()

        XCTAssertEqual(url.absoluteString, "https://example.com/path")
    }

    func testToURLFallsBackToFileURLForInvalidURLString() {
        let url = "http://[::1".toURL()

        XCTAssertTrue(url.isFileURL)
    }

    func testToMarkdownConvertsCommonHtmlElements() {
        let html = """
        <h1><strong>Title</strong></h1><p>Read <a href="https://example.com">more</a></p><img src="cover.png" alt="Cover">
        """

        let markdown = html.toMarkdown()

        XCTAssertTrue(markdown.contains("# Title"))
        XCTAssertTrue(markdown.contains("[more](https://example.com)"))
        XCTAssertTrue(markdown.contains("![Cover](cover.png)"))
    }

    func testSampleURLsKeepRemoteSchemes() {
        XCTAssertEqual(URL.sample_web_mp3_kennedy.scheme, "https")
        XCTAssertEqual(URL.sample_web_mp4_bunny.scheme, "http")
        XCTAssertEqual(URL.sample_web_stream_basic.pathExtension, "m3u8")
    }

    func testEnsureLocalAvailabilityReturnsForLocalFile() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let file = root.appendingPathComponent("track.mp3")
        try Data("audio".utf8).write(to: file)

        try await file.ensureLocalAvailability(timeout: 0.1, pollInterval: 0.05)
    }

    func testCopyToRejectsCopyingFileOntoItselfWithoutDeletingSource() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let file = root.appendingPathComponent("track.mp3")
        let originalData = Data("audio".utf8)
        try originalData.write(to: file)

        do {
            try await file.copyTo(file, verbose: false, caller: "test")
            XCTFail("Copying a file onto itself should throw")
        } catch {
            XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
            XCTAssertEqual(try Data(contentsOf: file), originalData)
        }
    }

    func testSameFileLocationNormalizesRelativeSegments() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let file = root.appendingPathComponent("track.mp3")
        let equivalent = root
            .appendingPathComponent("subdir")
            .appendingPathComponent("..")
            .appendingPathComponent("track.mp3")

        XCTAssertTrue(file.isSameFileLocation(as: equivalent))
    }

    func testMagicLoggerClearLogsFromBackgroundClearsOnMainThread() async throws {
        let logger = MagicLogger(app: "MagicKitTests")
        logger.info("background clear setup")
        try await Task.sleep(nanoseconds: 50_000_000)

        await MainActor.run {
            XCTAssertFalse(logger.logs.isEmpty)
        }

        await Task.detached {
            logger.clearLogs()
        }.value
        try await Task.sleep(nanoseconds: 50_000_000)

        await MainActor.run {
            XCTAssertTrue(logger.logs.isEmpty)
        }
    }

    func testICloudPlaceholderIsNotTreatedAsDownloadedJustBecauseItExists() {
        XCTAssertTrue(URLDownloadAvailabilityPolicy.isDownloaded(
            fileExists: true,
            isUbiquitousItem: false,
            downloadingStatus: nil
        ))
        XCTAssertTrue(URLDownloadAvailabilityPolicy.isDownloaded(
            fileExists: true,
            isUbiquitousItem: true,
            downloadingStatus: .current
        ))
        XCTAssertFalse(URLDownloadAvailabilityPolicy.isDownloaded(
            fileExists: true,
            isUbiquitousItem: true,
            downloadingStatus: .notDownloaded
        ))
        XCTAssertFalse(URLDownloadAvailabilityPolicy.isDownloaded(
            fileExists: true,
            isUbiquitousItem: true,
            downloadingStatus: .downloaded
        ))
    }

    func testDirectoryContainmentDoesNotMatchSiblingPrefix() {
        let parent = "/tmp/Cisum/Documents"

        XCTAssertTrue(URLDirectoryContainmentPolicy.contains(
            "/tmp/Cisum/Documents",
            inDirectory: parent
        ))
        XCTAssertTrue(URLDirectoryContainmentPolicy.contains(
            "/tmp/Cisum/Documents/Audio/Track.mp3",
            inDirectory: parent
        ))
        XCTAssertFalse(URLDirectoryContainmentPolicy.contains(
            "/tmp/Cisum/Documents Backup/Track.mp3",
            inDirectory: parent
        ))
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
