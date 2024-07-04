import Foundation
import OSLog
import SwiftData

extension DBSynced {
    // MARK: Find
    
    func findSceneState(_ scene: DiskScene) -> SceneState? {
        os_log("\(self.label)FindSceneState for \(scene.title)")
        do {
            return try context.fetch(SceneState.descriptorOf(scene)).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            
            return nil
        }
    }
    
    func getSceneCurrent(_ scene: DiskScene) -> URL? {
        return self.findSceneState(scene)?.currentURL
    }
    
    // MARK: Update
    
    func updateSceneCurrent(_ scene: DiskScene, currentURL: URL?) {
        os_log("\(self.label)UpdateSceneCurrent: \(scene.title) -> \(currentURL?.lastPathComponent ?? "")")
        if let state = self.findSceneState(scene) {
            state.currentURL = currentURL
        } else {
            context.insert(SceneState(scene: scene, currentURL: currentURL))
        }
        
        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}
