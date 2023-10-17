//
//  内倒.swift どれぐらい谷側に重心が移動しているのか？
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2023/09/25.
//

import Foundation
import Spatial
import simd

class InclineCoM : ObservableObject,SteeringAngleFinder{
    var timeStamp: TimeInterval = Date.now.timeIntervalSince1970{
        willSet{
            lastTimeStamp = timeStamp
        }
    }
    
    var lastTimeStamp: TimeInterval = Date.now.timeIntervalSince1970
    
    var timeDuration: TimeInterval {
        get{
            abs(timeStamp - lastTimeStamp)
        }
    }

    // 前向きのベクトルを設定する スマホの画面上が +y方向 (x:0,y:1,z: 0)
    let fowardVector = Vector3D.up
    // 北を絶対値x0とするフォールライン方向
    var fallLineDirectionZVerticalXTrueNorth : Rotation3D = Rotation3D()
    // 北を絶対値z0とする現在のスキーの向きと姿勢
    var skiDirectionAbsoluteByNorth: Rotation3D = Rotation3D()
    // スキーセンターからスキーに対して垂直な重心の距離と向き
    var centerOfMassRelativeDirectionFromSki: Point3D = Point3D()
    
    func receiveUWBMeasuredData(data: UWBMeasuredData){
        centerOfMassRelativeDirectionFromSki = data.realDistance
        timeStamp = data.timeStamp
        
    }
    
    func receiveDeviceMotion(motion: DeviceMotion,skiTurnPhase: SkiTurnPhase){
        self.skiDirectionAbsoluteByNorth = motion.attitude
        self.turnYawingSide = skiTurnPhase.turnYawingSide
        self.timeStamp = motion.timeStamp
        self.fallLineDirectionZVerticalXTrueNorth = skiTurnPhase.fallLine
    }
    
    init(){}
    
    var turnYawingSide : TurnYawingSide = .Straight
}

protocol InclineCoMProtocol:TimeStamp{
    var fowardVector: Vector3D {get}
    var skiDirectionAbsoluteByNorth: Rotation3D {get}
    var centerOfMassRelativeDirectionFromSki: Point3D {get}
    var fallLineDirectionZVerticalXTrueNorth: Rotation3D {get}
}
extension InclineCoMProtocol{
    var currentTrueNorthZVerticalCenterOfMass: Point3D {
        get{
            centerOfMassRelativeDirectionFromSki.rotated(by: skiDirectionAbsoluteByNorth)
        }
    }
    var fallLineVector: Vector3D{
        get {
            fowardVector.rotated(by: fallLineDirectionZVerticalXTrueNorth)
        }
    }
    var horizontalDirOfFallLine: Vector3D{
        get {
            Vector3D(x: fallLineVector.x, y: fallLineVector.y, z: 0)
        }
    }
    var gravityHorizontalDistanceFromSkiCenterToCoM : Double {
        get {
            // xnorth かつz vertical なスキーの中心原点の重心位置とフォールラインの水平方向ベクトルの内積
            // 現在の前方が x1の時北に１の場合のはずこれのベクトルと
            simd_dot(currentTrueNorthZVerticalCenterOfMass.vector ,horizontalDirOfFallLine.normalized.vector)
        }
    }
}


protocol SteeringAngleFinder:InclineCoMProtocol{
    
}
extension SteeringAngleFinder{
    
    // いなないかも
    //    var skiVector: Vector3D {
    //        get{
    //            vectorYInNroth.rotated(by: skiDirectionAbsoluteByNorth)
    //        }
    //    }
    
    // ターン前半マイナス　後半プラスで評価したい
    var sterlingAngle : Angle2D{
        get{
            Angle2D(radians:
                        (fallLineDirectionZVerticalXTrueNorth.inverse * skiDirectionAbsoluteByNorth).eulerAngles(order: .xyz).angles.z
                    //                        acos(horizontalDirOfFallLine.normalized.dot(skiVector.normalized))
            )
        }
    }
    var 谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか : Double {
        sin(sterlingAngle) * gravityHorizontalDistanceFromSkiCenterToCoM
    }
}

extension Array where Element == InclineCoM {
    func いちターンでの内倒合計 ()-> Double{
        self.map{$0.gravityHorizontalDistanceFromSkiCenterToCoM * $0.timeDuration}.reduce(0, +)
    }
    
    func いちターンでの谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか ()-> Double {
        self.map{$0.谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか * $0.timeDuration}.reduce(0, +)
    }
}
