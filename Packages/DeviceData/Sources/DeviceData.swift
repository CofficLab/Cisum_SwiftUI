import Foundation
import SwiftData

@Model
public final class DeviceData {
    public static let descriptorAll = FetchDescriptor(
        predicate: #Predicate<DeviceData> { _ in true },
        sortBy: [
            SortDescriptor(\.firstOpenTime, order: .forward)
        ]
    )

    public var uuid: String = ""
    public var firstOpenTime: Date = Date.distantPast
    public var lastOpenTime: Date = Date.distantPast
    public var timesOpened: Int = 0
    public var audioCount: Int = 0
    public var name: String = ""
    public var model: String = ""
    public var os: String = ""
    public var version: String = ""

    public init(uuid: String) {
        self.uuid = uuid
    }
}
