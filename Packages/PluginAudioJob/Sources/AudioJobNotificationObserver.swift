import CisumUIComponents
import Combine
import Foundation

@MainActor
final class AudioJobNotificationObserverHolder {
    static let shared = AudioJobNotificationObserverHolder()
    var cancellables = Set<AnyCancellable>()
    private init() {}
}
