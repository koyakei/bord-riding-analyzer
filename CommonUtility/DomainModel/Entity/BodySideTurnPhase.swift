//
//  BodySideTurnPhase.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/09.
//

import Foundation
import Spatial
import CoreMotion

protocol BodySideTurnPhaseProtocol :DeviceMotionProtocol , UWBMeasuredDataProtocol{
    var beforeTimeStapm: TimeInterval { get }
}

extension BodySideTurnPhaseProtocol{
    
    var スキーに垂直な方向の加速度掛ける時間: Double{
        get {
            スキーに垂直方向の加速度 * ( timeStamp - beforeTimeStapm)
        }
    }
    
    var スキーに垂直方向の加速度 : Double {
        get {
            direction.normalized.dot( userAcceleration + gravity)
        }
    }
    
    var zがどれだけ斜め : Vector3D {
        get {
            direction.normalized
        }
    }
    
    var centerOfMassTurnPhase : CenterOfMassTurnPhase {
        get {
            CenterOfMassTurnPhase(gravity: gravity, attitude: attitude, rotationRate: rotationRate, userAcceleration: userAcceleration, timeStamp: timeStamp, スキーに垂直方向の加速度: スキーに垂直方向の加速度)
        }
    }
    
    
}

struct BodySideTurnPhase: BodySideTurnPhaseProtocol, UWBMeasuredDataProtocol,Codable{
    var beforeTimeStapm: TimeInterval
    
    var gravity: Vector3D
    
    var attitude: Rotation3D
    
    var rotationRate: Vector3D
    
    var userAcceleration: Vector3D
    
    var direction: Vector3D
    
    var timeStamp: TimeInterval
    
    mutating func recieveMotion(deviceMotion : DeviceMotion){
        attitude = deviceMotion.attitude
        rotationRate = deviceMotion.rotationRate
        userAcceleration = deviceMotion.userAcceleration
        timeStamp = deviceMotion.timeStamp
        gravity = deviceMotion.gravity
        beforeTimeStapm = timeStamp
    }
    
    mutating func recieveDistance(distance : UWBMeasuredData){
        direction = distance.direction
        timeStamp = distance.timeStamp
        beforeTimeStapm = timeStamp
    }
}
