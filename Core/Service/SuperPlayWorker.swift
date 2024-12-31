import Foundation

protocol SuperPlayWorker {
    var duration: TimeInterval { get }
    var currentTime: TimeInterval { get }
    var state: PlayState { get }
    
    func seek(_ time: TimeInterval)
    func prepare(_ asset: PlayAsset, reason: String, verbose: Bool) throws
    func play(_ asset: PlayAsset, reason: String, verbose: Bool) throws
    func pause(verbose: Bool) throws
    func resume(_ asset: PlayAsset?) throws
    func stop(reason: String, verbose: Bool)
    func toggle() throws
    func setError(_ e: Error, asset: PlayAsset?)
}
