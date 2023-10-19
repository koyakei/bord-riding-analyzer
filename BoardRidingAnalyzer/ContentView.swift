//
//  ContentView.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/08.
//

import SwiftUI
import Spatial
struct ContentView: View {
    @StateObject var mpcManager : MPCManager
    @StateObject var mPCNIDelegateManager : MPCNIDelegateManager
    @StateObject var boardSideBodyMotionReciever : BoardSideBodyMotionReciever
    @StateObject var inclineCoM : InclineCoM
    @StateObject var boardMotionManager: BoardMotionManager
    
    let kneeAngle: KneeAngle = KneeAngle()
    var body: some View {
        VStack {
            TextField("プレースホルダー", text: $mpcManager.message)
            Button("sendm"){
                mpcManager.sendMessage()
            }
            
            HStack{
                Text("内倒度合い")
                Text(inclineCoM.gravityHorizontalDistanceFromSkiCenterToCoM.f2)
                
            }
            HStack{
                Text("谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか")
                Text(boardMotionManager.いちターンでの谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか.f2)
            }
            
            HStack{
                Toggle(isOn: self.$boardMotionManager.内倒音声読み上げ) {
                            Text(boardMotionManager.内倒音声読み上げ ? "OFF" : "ON")
                        }
                Text("１ターンの合計内倒度合い")
                Text(boardMotionManager.beforeいちターンでの内倒合計.f2)
                
            }
            
            Text(mPCNIDelegateManager.uwbMeasuredData?.realDistance.realPoint3DByCentimeter.description ?? "nasi").font(.title)
            
            
            VStack{
                if let receivedTime = mPCNIDelegateManager.uwbMeasuredData?.timeStamp {
                    Text((receivedTime - Date.now.timeIntervalSince1970).f2)
                }
               
            }
            Button("start uwb"){
                mPCNIDelegateManager.shareMyDiscoveryToken()
            }
            Text(
                boardSideBodyMotionReciever.beforeOneTurnAT.f2
            )
            VStack{
                Text("knee angle")
                Text(kneeAngle.data(bodyUWBMeasuredPoint: mPCNIDelegateManager.uwbMeasuredData?.realDistance ?? Point3D()).degrees.f2
                ).font(.title)
            }
        }.onAppear(perform: {
            mpcManager.startup()
            mPCNIDelegateManager.startup()
        })
    }
}

// ここで読み上げもやるか。 interface 側にしよう
