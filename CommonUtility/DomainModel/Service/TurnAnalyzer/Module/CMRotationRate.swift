//
//  CMRotationRate.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/09.
//

import Foundation
import CoreMotion

extension CMRotationRate {
    var yawingSide: TurnYawingSide {
        get{
            switch z {
            case -.infinity..<PhysicsConstants.degree * -1:
                return TurnYawingSide.RightYawing
            case PhysicsConstants.degree...Double.infinity:
                return TurnYawingSide.LeftYawing
            default:
                return TurnYawingSide.Straight
            }
        }
    }
}


