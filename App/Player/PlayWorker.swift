import Foundation

protocol PlayWorker {
    var duration: TimeInterval { get }
    var currentTime: TimeInterval { get }
    var state: PlayState { get }
    
    func toggleLike()
    func goto(_ time: TimeInterval)
    func prepare(_ asset: PlayAsset?)
    func play(_ asset: PlayAsset, reason: String)
    func play()
    func resume()
    func pause()
    func stop()
    func toggle()
    func prev()
}
