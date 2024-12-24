import Foundation
import SwiftUI

protocol PlaySource {
    func delete() async throws
    func download() async throws
    func toggleLike() async throws
    func getCoverImage(verbose: Bool) async throws -> Image?
    func getCoverFromMeta(verbose: Bool) async throws -> URL?
}
