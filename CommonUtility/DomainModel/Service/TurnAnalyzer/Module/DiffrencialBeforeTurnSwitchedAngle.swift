//
//  DiffrencialBeforeTurnSwitchedAngle.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/09.
//

import Foundation
import Spatial
struct DiffrencialBeforeTurnSwitchedAngle {
    var lastTurnSwitchAngle: Rotation3D = Rotation3D()
    
    mutating func switched (currentAttitude : Rotation3D){
        lastTurnSwitchAngle = currentAttitude
    }
    
    func currentYawingDiffrencial(currentAttitude : Rotation3D) -> Angle2D{
        Angle2D(radians: (currentAttitude * lastTurnSwitchAngle.inverse).eulerAngles(order: .xyz).angles.z)
    }
    
    func currentDiffrencial(currentAttitude : Rotation3D) -> Angle2D{
        (currentAttitude * lastTurnSwitchAngle.inverse).angle
    }
}
