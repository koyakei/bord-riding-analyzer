//
//  SkiTurnPhaseAnalyzer.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/09.
//

import Foundation
import Spatial
struct SkiTurnPhaseAnalyzer {
    var turnSwitchingDirectionFinder = TurnSwitchingDirectionFinder()
    var absoluteFallLineFinder =
    AbsoluteFallLineFinder()
    var diffrencialBeforeTurnSwitchedAngle = DiffrencialBeforeTurnSwitchedAngle()
    var turnSideChangingPeriodFinder = TurnSideChangingPeriodFinder()
    
    init(){
        turnSideChangingPeriodFinder.turnSwitchedReceiver.append (
            diffrencialBeforeTurnSwitchedAngle.switched
        )
    }
    // 観測結果を返したほうが良いのかな？　内倒を返すか。
    mutating func handle(deviceMotion: DeviceMotion)-> SkiTurnPhase{
        turnSwitchingDirectionFinder.handle(currentTimeStampSince1970: deviceMotion.timeStamp, currentYawingSide: deviceMotion.rotationRate.yawingSide)
        let fl = absoluteFallLineFinder.handle(quaternion: deviceMotion.attitude.quaternion, timeStampSince1970: deviceMotion.timeStamp, yawingPeriod: turnSideChangingPeriodFinder.period)
        let diffPercentage = diffrencialBeforeTurnSwitchedAngle.turnPercentageBy3dAngleDiff(currentAttitude: deviceMotion.attitude)
        turnSideChangingPeriodFinder.recieveMotion(rotationRate: deviceMotion.rotationRate, timeInterval: deviceMotion.timeStamp,currentAttitude: deviceMotion.attitude)
        return SkiTurnPhase(gravity: deviceMotion.gravity, attitude: deviceMotion.attitude, rotationRate: deviceMotion.rotationRate, userAcceleration: deviceMotion.userAcceleration, timeStamp: deviceMotion.timeStamp, fallLine: fl, turnYawingSide: deviceMotion.rotationRate.yawingSide,turnPeriod: turnSideChangingPeriodFinder.period,diffPercentage: diffPercentage)
    }
}
