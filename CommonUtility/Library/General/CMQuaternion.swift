//
//  CMQuaternion.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2023/10/05.
//

import simd
import CoreMotion
import Spatial

extension CMQuaternion{
    var simdQuat : simd_quatd {
        get {
            simd_quatd(vector: [x,y,z,w])
        }
    }
    
    var rotation3D : Rotation3D {
        get {
            Rotation3D(simdQuat)
        }
    }
}
