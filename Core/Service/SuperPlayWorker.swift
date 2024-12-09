import Foundation

protocol SuperPlayWorker {
    var duration: TimeInterval { get }
    var currentTime: TimeInterval { get }
    var state: PlayState { get }
    
    func goto(_ time: TimeInterval)
    func prepare(_ asset: PlayAsset?, reason: String)
    func play(_ asset: PlayAsset, reason: String) throws
    func play() throws
    func pause(verbose: Bool) throws
    func stop(reason: String)
    func toggle() throws
    func setError(_ e: Error, asset: PlayAsset?)
}
