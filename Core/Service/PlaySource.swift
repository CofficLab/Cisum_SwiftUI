import Foundation

protocol PlaySource {
    func delete() async throws
    func download() async throws
    func toggleLike() async throws
}
