import Foundation
import OSLog
import SwiftData


// MARK: 增加

extension DBSynced {
    func insertDeviceData() {
        let deviceData = DeviceData(uuid: AppConfig.uuid)
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
        let uuid = AppConfig.uuid
        
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
                insertDeviceData()
            }
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
