//
//  SkiTurnPhase.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/09.
//

import Foundation
import Spatial
struct SkiTurnPhase : TimeStamp,DeviceMotionProtocol{
    let gravity: Vector3D
    
    let attitude: Rotation3D
    
    let rotationRate: Vector3D
    
    let userAcceleration: Vector3D
    
    let timeStamp: TimeInterval
    
    let fallLine : Rotation3D
    
    let turnYawingSide: TurnYawingSide
    
    let turnPeriod: TimeInterval
    let diffPercentage: Double
}


struct CenterOfMassTurnPhase: TimeStamp,DeviceMotionProtocol{
    let gravity: Vector3D
    
    let attitude: Rotation3D
    
    let rotationRate: Vector3D
    
    let userAcceleration: Vector3D
    
    let timeStamp: TimeInterval
    
    let スキーに垂直方向の加速度: Double
}


