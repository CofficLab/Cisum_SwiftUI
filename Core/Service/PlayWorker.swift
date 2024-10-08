import Foundation

protocol PlayWorker {
    var duration: TimeInterval { get }
    var currentTime: TimeInterval { get }
    var state: PlayState { get }
    
    func goto(_ time: TimeInterval)
    func prepare(_ asset: PlayAsset?, reason: String)
    func play(_ asset: PlayAsset, reason: String)
    func play()
    func resume()
    func pause()
    func stop(reason: String)
    func toggle()
    func setError(_ e: Error, asset: PlayAsset?)
}
