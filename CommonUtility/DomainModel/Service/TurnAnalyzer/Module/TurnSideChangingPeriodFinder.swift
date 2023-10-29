//
//  TurnSideChangingPeriodFinder.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/09.
//

import Foundation
import Spatial

struct TurnSideChangingPeriodFinder{
    var lastSwitchedTurnSideTimeStamp: TimeInterval = Date.now.timeIntervalSince1970{
        willSet{
            beforelastSwitchedTurnSideTimeStamp = lastSwitchedTurnSideTimeStamp
        }
    }
    private var beforelastSwitchedTurnSideTimeStamp: TimeInterval = Date.now.timeIntervalSince1970 - 2
    var period: TimeInterval {
        get{
            lastSwitchedTurnSideTimeStamp - beforelastSwitchedTurnSideTimeStamp
        }
    }
    
    let minTurnPeriod : TimeInterval = 0.8
    let ターン切り替え時とみなす最大角速度 = 5.0
    func isOverMinTurnPeriod(timeStamp: TimeInterval) -> Bool {
        (timeStamp - lastSwitchedTurnSideTimeStamp) > minTurnPeriod
    }
    var turnSwitchedReceiver: [((Rotation3D)-> Void)] = []
    
    mutating func recieveMotion(rotationRate: Vector3D, timeInterval : TimeInterval,currentAttitude : Rotation3D)-> Bool{
        let res = abs(rotationRate.z) < Angle2D(degrees: ターン切り替え時とみなす最大角速度).radians
        && isOverMinTurnPeriod(timeStamp: timeInterval)
        if res {
            lastSwitchedTurnSideTimeStamp = timeInterval
            turnSwitchedReceiver.map{
                handler in
                handler(currentAttitude)
            }
        }
        return res
    }
}
