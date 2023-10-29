//
//  TurnSwitchingDirectionFinder.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/09.
//

import Foundation
struct TurnSwitchingDirectionFinder{
    var lastYawingSide: TurnYawingSide = TurnYawingSide.Straight
    mutating func handle
            (currentTimeStampSince1970: TimeInterval, currentYawingSide: TurnYawingSide) -> TurnSwitchingDirection {
        switch (lastYawingSide, currentYawingSide){
        case(.Straight, .LeftYawing):
            lastYawingSide = currentYawingSide
            return .StraightToLeftTurn
        case (.Straight, .RightYawing):
            lastYawingSide = currentYawingSide
            return .StraightToRightTurn
        case (.RightYawing, .LeftYawing):
            lastYawingSide = currentYawingSide
            return .RightToLeft
        case (.LeftYawing, .RightYawing):
            lastYawingSide = currentYawingSide
            return .LeftToRight
        case (.LeftYawing, .Straight):
            lastYawingSide = currentYawingSide
            return .RightTurnToStraight
        case (.RightYawing, .Straight):
            lastYawingSide = currentYawingSide
            return .RightTurnToStraight
        default:
            return .Keep
        }
    }
}
