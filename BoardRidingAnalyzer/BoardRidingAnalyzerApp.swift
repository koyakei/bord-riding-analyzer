//
//  BoardRidingAnalyzerApp.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/08.
//

import SwiftUI
import MultipeerConnectivity
import Spatial
@main
struct BoardRidingAnalyzerApp: App {
    var mpcManager : MPCManager = MPCManager()
    var mPCNIDelegateManager : MPCNIDelegateManager
    var uwbRepository:  UWBDataRepository = UWBDataRepository()
    var boardSideBodyMotionReciever:BoardSideBodyMotionReciever
    var boardMotionManager : BoardMotionManager
    var inclineCoM = InclineCoM()
    
    init(){
        boardMotionManager = BoardMotionManager( inclineCoM: &inclineCoM)
        mPCNIDelegateManager = MPCNIDelegateManager(
            mpc: mpcManager.mpc
        )
        boardSideBodyMotionReciever = BoardSideBodyMotionReciever(
            mpcManager: mpcManager
        )
        mpcManager.mpc.peerDataReciever.append(
            recieveUWB
        )
        mPCNIDelegateManager.uwbMeasuredHandler.append(inclineCoM.receiveUWBMeasuredData)
        boardMotionManager.skiTurnAnalyzer.turnSwitchedHandler.append(
            boardSideBodyMotionReciever.turnSwitched
        )
    }
    
    func recieveUWB(
        data: Data,
        peer: MCPeerID
    ){
        if let measuredData = try? JSONDecoder().decode(
            UWBMeasuredData.self,
            from: data
        ){
            uwbRepository.recieve(
                data: measuredData
            )
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                mpcManager: mpcManager,
                mPCNIDelegateManager: mPCNIDelegateManager,
                boardSideBodyMotionReciever: boardSideBodyMotionReciever, inclineCoM: inclineCoM
            )
        }
    }
}

