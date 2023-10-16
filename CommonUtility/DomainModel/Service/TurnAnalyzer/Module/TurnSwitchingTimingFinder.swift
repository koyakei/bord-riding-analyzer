//
//  TurnSwitchingTimingFinder.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/09.
//

import Foundation
import Spatial

struct TurnSwitchingTimingFinder{
    var turnSideChangingPeriodFinder: TurnSideChangingPeriodFinder
    
    mutating func handle(rotationRate: Vector3D, timeInterval : TimeInterval)-> Bool{
        let res = abs(rotationRate.z) < Measurement(value: -10
                                            , unit: UnitAngle.degrees)
                                    .converted(to: .radians).value
            && turnSideChangingPeriodFinder.isOverMinTurnPeriod()
        if res {
            turnSideChangingPeriodFinder.turnSwitched(currentTimeStampSince1970: timeInterval)
        }
        return res
    }
}
