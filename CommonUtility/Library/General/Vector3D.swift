//
//  Vector3D.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/11/12.
//

import Foundation
import Spatial
import SceneKit

extension Vector3D{
    var sceneKitVector : Vector3D{
        get {
            SCNVector3FromGLKVector3(GLKVector3(v: (Float(x), Float(y), Float(z)))).vector3D
        }
    }
}
