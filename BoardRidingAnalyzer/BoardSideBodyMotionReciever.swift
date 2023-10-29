//
//  BoardSideBodyMotionReciever.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/08.
//

import Foundation
import MultipeerConnectivity
import Spatial
class BoardSideBodyMotionReciever : ObservableObject{
    var mpcManager : MPCManager
    @Published var bodySideTurnPhase: BodySideTurnPhase? = nil
    
    var beforeOneTurnAT: Double {
        get{
            oneTurnDeviceMotions.map{$0.スキーに垂直な方向の加速度掛けるmillSecond}.reduce(0,+)
        }
    }
    var oneTurnDeviceMotions: [BodySideTurnPhase] = []
    
    func turnSwitched(currentAttitude : Rotation3D){
        oneTurnDeviceMotions.removeAll()
    }
    
    init(mpcManager: MPCManager) {
        self.mpcManager = mpcManager
        self.mpcManager.mpc.peerDataReciever.append(boardDeviceMotionReciever)
    }
    
    // 受信したものを何処かにためて表示
    func boardDeviceMotionReciever(data: Data, peer: MCPeerID ){
        if let motion = try? JSONDecoder().decode(BodySideTurnPhase.self, from: data){
            self.bodySideTurnPhase = motion
        }
    }
}

