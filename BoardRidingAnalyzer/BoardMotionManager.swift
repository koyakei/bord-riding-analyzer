//
//  BoardMotionManager.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/08.
//

import Foundation
import CoreMotion
import MultipeerConnectivity

class BoardMotionManager :ObservableObject {
    let coremotionManager = CMMotionManager()
    var skiTurnAnalyzer = SkiTurnPhaseAnalyzer()
    var inclineCom: InclineCoM
    init (inclineCoM: inout InclineCoM){
        self.inclineCom = inclineCoM
    }
    var inclineCoMs : [InclineCoM] = []
    @Published var beforeいちターンでの内倒合計: Double = 0
    @Published var いちターンでの谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか: Double = 0
    var 内倒音声読み上げ = false
    var いちターンでの谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか音声読み上げ = false
    func turnSwitched(){
        self.beforeいちターンでの内倒合計 = inclineCoMs.いちターンでの内倒合計()
        self.いちターンでの谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか = inclineCoMs.いちターンでの谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか()
        inclineCoMs.removeAll()
        
        if 内倒音声読み上げ{
            Speecher.speeche(text: self.beforeいちターンでの内倒合計.description)
        }
        
        if いちターンでの谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか音声読み上げ{
            Speecher.speeche(text: self.いちターンでの谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか.description)
        }
    }
    
    func start(){
        coremotionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical,to: .current!) { motion, error in
            if let motion = motion{
                let res = self.skiTurnAnalyzer.handle(deviceMotion: motion.deviceMotion)
                self.inclineCom.receiveDeviceMotion(motion: motion.deviceMotion, skiTurnPhase: res)
                self.inclineCoMs.append(self.inclineCom)
            }
            
        }
    }
}


