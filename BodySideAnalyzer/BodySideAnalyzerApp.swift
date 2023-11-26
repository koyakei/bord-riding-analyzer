//
//  BodySideAnalyzerApp.swift
//  BodySideAnalyzer
//
//  Created by koyanagi on 2023/10/08.
//

import SwiftUI
import Spatial
import CoreMotion

@main
struct BodySideAnalyzerApp: App ,BoardMotionReciverDelegate ,UwbMeasuredMutatingDelegate{
    mutating func measured(uwbMeasuredData: UWBMeasuredData) {
        bodyMotionManager.bodySideTurnPhase.recieveDistance(distance: uwbMeasuredData)
    }
    
    var mpcManager : MPCManager = MPCManager()
    var mPCNIDelegateManager : MPCNIDelegateManager
    var bodyMotionManager : BodyMotionManager
    
    init(){
        mPCNIDelegateManager = MPCNIDelegateManager(mpc: mpcManager.mpc)
        bodyMotionManager = BodyMotionManager(mpcManager: mpcManager)
        mPCNIDelegateManager.uwbMeasuredMutatingDelegate = self
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(mpcManager: mpcManager,
                        mPCNIDelegateManager: mPCNIDelegateManager, bodyMotionManager: bodyMotionManager,
                        initRotationNorthX: bodyMotionManager.bodySideTurnPhase.attitude)
        }
    }
    
    mutating func reciever(motion: CMDeviceMotion) {
        bodyMotionManager.bodySideTurnPhase.recieveMotion(deviceMotion: motion.deviceMotion)
        if let data = try? JSONEncoder().encode(bodyMotionManager.bodySideTurnPhase){
            mpcManager.mpc.sendDataToAllPeers(data: data)
        }
    }
}



