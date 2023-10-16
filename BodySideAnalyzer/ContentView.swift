//
//  ContentView.swift
//  BodySideAnalyzer
//
//  Created by koyanagi on 2023/10/08.
//

import SwiftUI

struct ContentView: View {
    @StateObject var mpcManager : MPCManager
    @StateObject var mPCNIDelegateManager : MPCNIDelegateManager
    @StateObject var bodyMotionManager: BodyMotionManager
    var body: some View {
        VStack {
            TextField("プレースホルダー", text: $mpcManager.message)
            Button("sendm"){
                mpcManager.sendMessage()
            }
            Text(mPCNIDelegateManager.uwbMeasuredData?.realDistance.realPoint3DByCentimeter.description ?? "nasi")
            Button("start uwb"){
                mPCNIDelegateManager.shareMyDiscoveryToken()
            }
            Button("start motion record"){
                bodyMotionManager.start()
            }
            HStack{
                Text("スキー方向に掛かる力")
                Text(
                    bodyMotionManager.bodySideTurnPhase.スキーに垂直方向の加速度.f2)
            }
            HStack{
                Text("userAcceleration")
                Text(
                    bodyMotionManager.bodySideTurnPhase.userAcceleration.f2)
            }
            
            HStack{
                Text("重力")
                Text(
                    bodyMotionManager.bodySideTurnPhase.gravity.f2)
            }
            
            HStack{
                Text("重力 + ac")
                Text(
                    (bodyMotionManager.bodySideTurnPhase.gravity  + bodyMotionManager.bodySideTurnPhase.userAcceleration).f2)
            }
            
            HStack{
                Text("zがどれだけ斜め")
                Text(bodyMotionManager.bodySideTurnPhase.zがどれだけ斜め.f2)
            }
            HStack{
                Text("正規化された距離")
                Text(bodyMotionManager.bodySideTurnPhase.direction.normalized.f2)
            }
            
        }.onAppear(perform: {
            mpcManager.startup()
            mPCNIDelegateManager.startup()
        })
    }
}


