//
//  SCNVector3.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/11/12.
//

import Foundation
import Spatial
import SceneKit

extension SCNVector3 {
    var vector3D :Vector3D{
        get {
            Vector3D(vector: [Double(x),Double(y),Double(z)])
        }
    }
}

extension SCNVector4 {
    var rotation3D :Rotation3D{
        get {
            Rotation3D.init(quaternion: simd_quatf(ix: x, iy: y, iz: z, r: w))
        }
    }
}
