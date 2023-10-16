//
//  BoardMotionManager.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/08.
//

import Foundation
import CoreMotion
import MultipeerConnectivity

class BoardMotionManager  {
    let coremotionManager = CMMotionManager()
    var skiTurnAnalyzer = SkiTurnPhaseAnalyzer()
    var inclineCom: InclineCoM
    init (inclineCoM: inout InclineCoM){
        self.inclineCom = inclineCoM
    }
    func start(){
        coremotionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical,to: .current!) { motion, error in
            if let motion = motion{
                let res = self.skiTurnAnalyzer.handle(deviceMotion: motion.deviceMotion)
                self.inclineCom.skiDirectionAbsoluteByNorth = motion.deviceMotion.attitude
                self.inclineCom.fallLineDirectionZVerticalXTrueNorth = res.fallLine
                self.inclineCom.turnYawingSide = motion.deviceMotion.rotationRate.yawingSide
            }
        }
    }
}


