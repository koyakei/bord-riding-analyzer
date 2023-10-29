//
//  BoardRidingAnalyzerApp.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/08.
//

import SwiftUI
import MultipeerConnectivity
import Spatial
import WatchConnectivity
@main
struct BoardRidingAnalyzerApp: App {
    var mpcManager : MPCManager = MPCManager()
    var mPCNIDelegateManager : MPCNIDelegateManager
    var uwbRepository:  UWBDataRepository = UWBDataRepository()
    var boardSideBodyMotionReciever: BoardSideBodyMotionReciever
    var boardMotionManager : BoardMotionManager
    var inclineCoM = InclineCoM(exportRidingData: ExportRidingData())
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
        mPCNIDelegateManager.uwbMeasuredHandler.append(receiveUWBMeasuredData)
        boardMotionManager.skiTurnAnalyzer.turnSideChangingPeriodFinder.turnSwitchedReceiver.append(
            boardSideBodyMotionReciever.turnSwitched
        )
        boardMotionManager.skiTurnAnalyzer.turnSideChangingPeriodFinder.turnSwitchedReceiver.append(
            boardMotionManager.turnSwitched
        )
        // icm 記録する場所を探そう
    }
    
    func receiveUWBMeasuredData(data: UWBMeasuredData,_: MPCSession){
        inclineCoM.receiveUWBMeasuredData(data: data)
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
                boardSideBodyMotionReciever: boardSideBodyMotionReciever, inclineCoM: inclineCoM,
                boardMotionManager: boardMotionManager
            )
        }
    }
}

