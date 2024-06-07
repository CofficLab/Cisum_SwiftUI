import Foundation
import OSLog
import SwiftData

extension DBSynced {
    func insertDeviceData(deviceId: String) {
        let deviceData = DeviceData(uuid: deviceId)
        deviceData.firstOpenTime = .now
        deviceData.lastOpenTime = .now
        deviceData.name = DeviceHelper.getDeviceName()
        deviceData.model = DeviceHelper.getDeviceModel()
        deviceData.os = DeviceHelper.getSystemName()
        deviceData.version = DeviceHelper.getSystemVersion()
        
        do {
            self.context.insert(deviceData)
            try self.context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
    
    func onAppOpen() {
        let uuid = AppConfig.getDeviceId()
        
        Task {
            if let deviceData = self.find(uuid) {
                deviceData.timesOpened += 1
                deviceData.lastOpenTime = .now
                deviceData.audioCount = await DB(AppConfig.getContainer).getTotalOfAudio()
                
                do {
                    try context.save()
                } catch let e {
                    os_log(.error, "\(e.localizedDescription)")
                }
            } else {
                insertDeviceData(deviceId: uuid)
            }
        }
    }
    
    // MARK: Delete
    
    func deleteDevice(_ deviceData: DeviceData) {
        os_log("\(self.label)Delete Device -> \(deviceData.name)")
        
        guard let dbItem = context.model(for: deviceData.id) as? DeviceData else {
            return
        }
        
        context.delete(dbItem)
        
        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
    
    // MARK: Read
    
    func find(_ uuid: String) -> DeviceData? {
        do {
            return try context.fetch(FetchDescriptor(predicate: #Predicate<DeviceData> {
                $0.uuid == uuid
            })).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            
            return nil
        }
    }
    
    func allDevices() -> [DeviceData] {
        do {
            return try context.fetch(DeviceData.descriptorAll)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            
            return []
        }
    }
}
