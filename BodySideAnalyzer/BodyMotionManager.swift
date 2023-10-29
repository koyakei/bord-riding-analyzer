//
//  BodyMotionManager.swift
//  BodySideAnalyzer
//
//  Created by koyanagi on 2023/10/08.
//
import Foundation
import CoreMotion
import MultipeerConnectivity
import Spatial

class BodyMotionManager :NSObject,ObservableObject {
    let coremotionManager = CMMotionManager()
    var mpcManager : MPCManager
    @Published var bodySideTurnPhase: BodySideTurnPhase = BodySideTurnPhase(beforeTimeStapm: Date.now.timeIntervalSince1970, gravity: Vector3D(), attitude: Rotation3D.init(), rotationRate: Vector3D.up, userAcceleration: Vector3D.up, direction: Vector3D.up, timeStamp: Date.now.timeIntervalSince1970)
    
    init(mpcManager: MPCManager) {
        self.mpcManager = mpcManager
    }
    func start(){
        coremotionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical,to: .current!) { motion, error in
            if let motion = motion{
                self.bodySideTurnPhase.recieveMotion(deviceMotion: motion.deviceMotion)
                if let data = try? JSONEncoder().encode(self.bodySideTurnPhase){
                    self.mpcManager.mpc.sendDataToAllPeers(data: data)
                }
            }
        }
    }
}

protocol BoardMotionReciverDelegate  {
    mutating func reciever(motion : CMDeviceMotion)
}
