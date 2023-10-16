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
    var turnSwitchingTimingFinder : TurnSwitchingTimingFinder
    init (){
        turnSwitchingTimingFinder = TurnSwitchingTimingFinder( turnSideChangingPeriodFinder: turnSideChangingPeriodFinder)
        turnSwitchedHandler.map{
            handler in
            turnSideChangingPeriodFinder.turnSwitchedReceiver.append(
                handler
            )
        }
    }
    
    var turnSwitchedHandler : [(()-> Void)] = []
    
    // 観測結果を返したほうが良いのかな？　内倒を返すか。
    mutating func handle(deviceMotion: DeviceMotion)-> SkiTurnPhase{
        turnSwitchingDirectionFinder.handle(currentTimeStampSince1970: deviceMotion.timeStamp, currentYawingSide: deviceMotion.rotationRate.yawingSide)
        let fl = absoluteFallLineFinder.handle(quaternion: deviceMotion.attitude.quaternion, timeStampSince1970: deviceMotion.timeStamp, yawingPeriod: turnSideChangingPeriodFinder.period)
        diffrencialBeforeTurnSwitchedAngle.currentYawingDiffrencial(currentAttitude: deviceMotion.attitude)
        turnSwitchingTimingFinder.handle(rotationRate: deviceMotion.rotationRate, timeInterval: deviceMotion.timeStamp)
        
        return SkiTurnPhase(gravity: deviceMotion.gravity, attitude: deviceMotion.attitude, rotationRate: deviceMotion.rotationRate, userAcceleration: deviceMotion.userAcceleration, timeStamp: deviceMotion.timeStamp, fallLine: fl, turnYawingSide: deviceMotion.rotationRate.yawingSide)
        
    }
    
    
    
}
