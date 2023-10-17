//
//  DeviceMotion.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/08.
//

import Foundation
import Spatial
import CoreMotion
import simd
struct DeviceMotion : Codable, DeviceMotionProtocol{
    let gravity: Vector3D
    let attitude: Rotation3D
    let rotationRate: Vector3D
    let userAcceleration: Vector3D
    let timeStamp: TimeInterval
}

protocol DeviceMotionProtocol : TimeStamp {
    var attitude: Rotation3D { get  }
    var rotationRate: Vector3D{ get  }
    var userAcceleration: Vector3D{ get  }
    var gravity: Vector3D {get}
}

extension Vector3D {
    var yawingSide: TurnYawingSide {
        get{
            switch Angle2D(radians: z).degrees {
            case -.infinity..<(-1):
                return TurnYawingSide.RightYawing
            case 1...Double.infinity:
                return TurnYawingSide.LeftYawing
            default:
                return TurnYawingSide.Straight
            }
        }
    }
}

extension CMRotationRate{
    var vector3D : Vector3D{
        get {
            Vector3D(x: self.x,y:self.y,z: self.z)
        }
    }
}
