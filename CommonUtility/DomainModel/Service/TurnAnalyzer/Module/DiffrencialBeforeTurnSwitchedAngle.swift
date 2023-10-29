//
//  DiffrencialBeforeTurnSwitchedAngle.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/09.
//

import Foundation
import Spatial
class DiffrencialBeforeTurnSwitchedAngle {
    var lastTurnSwitchAngle: Rotation3D = Rotation3D(){
        willSet{
            beforeLastTurnSwitchAngle = lastTurnSwitchAngle
        }
    }
    var beforeLastTurnSwitchAngle: Rotation3D = Rotation3D()
    
    var beforeDiffrencial : Rotation3D{
        get {
            lastTurnSwitchAngle * beforeLastTurnSwitchAngle.inverse
        }
    }
    // 今の違いの絶対値　/ 前のいちターンの違い絶対値
    func turnPercentageBy3dAngleDiff(currentAttitude : Rotation3D) -> Double{
        currentDiffrencial(currentAttitude : currentAttitude).angle.degrees /
            beforeDiffrencial.angle.degrees
    }
    
    // 代入だけなら関数である必要ないだろ
    func switched (currentAttitude : Rotation3D){
        lastTurnSwitchAngle = currentAttitude
    }
    
    
    func currentDiffrencial(currentAttitude : Rotation3D)-> Rotation3D{
        (currentAttitude * lastTurnSwitchAngle.inverse)
    }
}
