//
//  CMLogItem.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2023/10/06.
//
import CoreMotion
import Foundation

extension CMDeviceMotion {
    
    // 起動時間が制限されるからまずい気がするんだけどなぁ init いじれるならいいけど
//    var timeIntervalSince1970 : TimeInterval{
//        get{
//            Date(timeInterval: self.timestamp, since: Date.now.addingTimeInterval(-ProcessInfo.processInfo.systemUptime)).timeIntervalSince1970
//        }
//    }
    var deviceMotion : DeviceMotion {
        get {
            DeviceMotion(gravity: self.gravity.vector3D, attitude: self.attitude.quaternion.rotation3D, rotationRate: self.rotationRate.vector3D, userAcceleration: self.userAcceleration.vector3D,timeStamp: Date(timeInterval: self.timestamp, since: Date.now
                .addingTimeInterval(-ProcessInfo.processInfo.systemUptime)).timeIntervalSince1970)
        }
    }
}
