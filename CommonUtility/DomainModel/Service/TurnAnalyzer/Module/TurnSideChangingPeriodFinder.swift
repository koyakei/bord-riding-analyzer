//
//  TurnSideChangingPeriodFinder.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/09.
//

import Foundation


struct TurnSideChangingPeriodFinder{
    var lastSwitchedTurnSideTimeStamp: TimeInterval = Date.now.timeIntervalSince1970
    var period: TimeInterval = TimeInterval.zero
    let minTurnPeriod = 0.7
    func isOverMinTurnPeriod() -> Bool {
        period > minTurnPeriod
    }
    var turnSwitchedReceiver: [(()-> Void)] = []
    
    mutating func handle(currentTimeStampSince1970: TimeInterval) ->TimeInterval{
        period = currentTimeStampSince1970 - lastSwitchedTurnSideTimeStamp
//       if (isTurnSwitching)  {
//            lastSwitchedTurnSideTimeStamp = currentTimeStampSince1970
//        }
        return period
    }
    
    mutating func turnSwitched(currentTimeStampSince1970: TimeInterval){
        lastSwitchedTurnSideTimeStamp = currentTimeStampSince1970
        turnSwitchedReceiver.map{
            handler in
            handler()
        }
    }
}
