import Foundation
import Testing
@testable import MagicKit

#if os(macOS)
@Test func shellRunSyncHandlesConcurrentCallers() throws {
    let lock = NSLock()
    var outputs: [String] = []
    var failures: [Error] = []

    DispatchQueue.concurrentPerform(iterations: 24) { index in
        do {
            let output = try Shell.runSync("printf '%s' \(index)")
            lock.lock()
            outputs.append(output)
            lock.unlock()
        } catch {
            lock.lock()
            failures.append(error)
            lock.unlock()
        }
    }

    #expect(failures.isEmpty)
    #expect(Set(outputs) == Set((0..<24).map(String.init)))
}
#endif
