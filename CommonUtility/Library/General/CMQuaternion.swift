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
            return simd_quatd(ix: self.x,
                              iy: self.y,
                              iz: self.z,
                              r: self.w)
        }
    }
    
    var rotation3D : Rotation3D {
        get {
            Rotation3D(self.simdQuat)
        }
    }
}
