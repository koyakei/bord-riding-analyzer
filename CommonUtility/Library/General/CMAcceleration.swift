//
//  CMAcceleration.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2023/10/06.
//

import Spatial
import CoreMotion
extension CMAcceleration {
    var vector3D: Vector3D {
        get {
            Vector3D(x: self.x, y: self.y ,z: self.z)
            }
    }
}

