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
//            TextField("プレースホルダー", text: $mpcManager.message)
//            Button("sendm"){
//                mpcManager.sendMessage()
//            }
            HStack{
                Text(inclineCoM.スマホの表裏.description)
                Text("fps")
                Text(mPCNIDelegateManager.fps.description)
            }
            HStack{
                Text("相手で測定したノーマルな相対位置")
                if let dir = boardSideBodyMotionReciever.bodySideTurnPhase?.direction{
                    Text(Point3D(dir).realPoint3DByCentimeter).font(.title)
                }
            }
            
            HStack{
                Text("自分測定相対位置　icm")
                Text(inclineCoM.centerOfMassRelativeDirectionFromSki.realPoint3DByCentimeter).font(.title)
                
            }
            HStack{
                Text("スマホのyを前方とした重心の位置")
                Text(inclineCoM.スマホのyを前方とした重心の位置.realPoint3DByCentimeter).font(.title)
            }
            
            HStack{
                Text("xy だけもう一回現在姿勢を * 　スマホのyを前方とした重心の位置")
                Text(Point3D(inclineCoM.fallLineHorizontal).realPoint3DByCentimeter).font(.title)
            }

            HStack{
                Text((inclineCoM.スマホのyを前方とした重心の位置.y - inclineCoM.gravityHorizontalDistanceFromSkiCenterToCoM.value).f2)
                Text("内倒度合い")
                
            }
            
            HStack{
                Text(inclineCoM.gravityHorizontalDistanceFromSkiCenterToCoM.converted(to: .centimeters).value.f2)
                
            }
            HStack{
                Text("内倒度合い ダダしい")
                Text(inclineCoM.gravityHorizontalDistanceFromSkiCenterToCoM.converted(to: .centimeters).value.f2)
            }
            
            HStack{
                Text("谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか")
                Text(inclineCoM.谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか.f2)
            }
            
            HStack{
                Toggle(isOn: self.$boardMotionManager.内倒音声読み上げ) {
                            Text(boardMotionManager.内倒音声読み上げ ? "OFF" : "ON")
                        }
                Text("１ターンの合計内倒度合い")
                Text(boardMotionManager.beforeいちターンでの内倒合計.f2)
                
            }
            
            HStack{
                Text("turn %")
                Text(inclineCoM.diffPercentageByAngle.f2)
                Text("turn period")
                Text(boardMotionManager.skiTurnAnalyzer.turnSideChangingPeriodFinder.period.f2)
            }
            HStack{
                Text("bodyとの時間差")
                if let res = boardSideBodyMotionReciever.bodySideTurnPhase?.timeStamp{
                    Text((res - Date.now.timeIntervalSince1970).f2)
                } else{ 
                    Text("計測不能")
                }
            }
            HStack{
                Text("自分のuwbとの時間差")
                if let receivedTime = mPCNIDelegateManager.uwbMeasuredData?.timeStamp {
                    Text((receivedTime - Date.now.timeIntervalSince1970).f2)
                } else {
                    Text("uwb計測不能")
                }
            }
            Button("start uwb"){
                mPCNIDelegateManager.shareMyDiscoveryToken()
            }
            Button("start motion"){
                boardMotionManager.start()
            }
            Text(
                boardSideBodyMotionReciever.beforeOneTurnAT.f2
            )
            
            HStack{
                Text("csv")
                Button("start"){
                    inclineCoM.exportRidingData.open()
                }
                Button("Stop"){
                    inclineCoM.exportRidingData.close()
                }
            }
            HStack{
                Text("knee angle")
                Text(kneeAngle.data(bodyUWBMeasuredPoint: mPCNIDelegateManager.uwbMeasuredData?.realDistance ?? Point3D()).degrees.f2
                ).font(.title)
            }
            HStack{
                Text("↑").background(.red).font(.largeTitle).rotationEffect(Angle.init(radians:
                                                                                        inclineCoM.diffRotationFromFallLineToSkiDirection.inverse.eulerAngles(order: .xyz).angles.x
                                                                                   ))
                Text("↑").background(.red).font(.largeTitle).rotationEffect(Angle.init(radians:
                                                                                        inclineCoM.diffRotationFromFallLineToSkiDirection.inverse.eulerAngles(order: .xyz).angles.y
                                                                                   ))
                Text("↑").background(.blue).font(.largeTitle).rotationEffect(Angle.init(radians: inclineCoM.diffRotationFromFallLineToSkiDirection.inverse.eulerAngles(order: .xyz).angles.z
                                                                                   ))
                Text("↑").background(.green).font(.largeTitle).rotationEffect(Angle.init(radians: inclineCoM.skiDirectionAbsoluteByNorth.eulerAngles(order: .xyz).angles.z
                                                                                   ))
            }
        }.onAppear(perform: {
            mpcManager.startup()
            mPCNIDelegateManager.startup()
        })
    }
}

// ここで読み上げもやるか。 interface 側にしよう
