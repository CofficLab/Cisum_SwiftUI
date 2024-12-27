import Foundation
import SwiftUI
import MagicKit

protocol PlaySource {
    func delete() async throws
    func toggleLike() async throws
    func getCoverImage(verbose: Bool) async throws -> Image?
    func getPlatformImage() async throws -> PlatformImage?
}
