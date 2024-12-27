import Foundation
import SwiftUI
import MagicKit
import MagicUI

protocol PlaySource {
    func delete() async throws
    func toggleLike() async throws
    func getCoverImage(verbose: Bool) async throws -> Image?
    func getPlatformImage() async throws -> PlatformImage?
}
