import Testing
@testable import KernelCore
import ProviderAppState

@MainActor
struct ProviderObservationTests {
    @Test
    func appStatePublishesSemanticEventsAndSupportsCancellation() {
        let service = BasicAppStateService()
        var receivedEvents: [String] = []

        let handle = service.addObserver { event in
            switch event {
            case .demoModeChanged(let enabled):
                receivedEvents.append("demo:\(enabled)")
            case .importingChanged(let importing):
                receivedEvents.append("importing:\(importing)")
            case .droppingChanged(let dropping):
                receivedEvents.append("dropping:\(dropping)")
            case .stateMessageChanged(let message):
                receivedEvents.append("message:\(message)")
            case .dbViewVisibilityChanged:
                break
            }
        }

        service.enterDemoMode()
        service.setImporting(true)
        service.setDragOperation(true)
        service.appendStateMessage("ready")

        #expect(receivedEvents == [
            "demo:true",
            "importing:true",
            "dropping:true",
            "message:ready"
        ])

        handle.cancel()
        service.exitDemoMode()
        #expect(receivedEvents.count == 4)
    }
}
