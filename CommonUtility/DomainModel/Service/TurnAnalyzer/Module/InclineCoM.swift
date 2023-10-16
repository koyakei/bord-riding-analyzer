//
//  内倒.swift どれぐらい谷側に重心が移動しているのか？
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2023/09/25.
//

import Foundation
import Spatial
import simd

class InclineCoM : ObservableObject{
    // 西向きの１前のベクトルを設定する
    let vectorYInNroth = Vector3D(x:-1,y:0,z: 0)
    // 北を絶対値x0とするフォールライン方向
    var fallLineDirectionZVerticalXTrueNorth : Rotation3D = Rotation3D()
    // 北を絶対値z0とする現在のスキーの向きと姿勢
    var skiDirectionAbsoluteByNorth: Rotation3D = Rotation3D()
    // スキーセンターからスキーに対して垂直な重心の距離と向き
    var centerOfMassRelativeDirectionFromSki: Point3D = Point3D()
    
    var skiVector: Vector3D {
        get{
            vectorYInNroth.rotated(by: skiDirectionAbsoluteByNorth)
        }
    }
    //重力に垂直なスキーの中心からの位置 ｙはフォールライン
    var gravityHorizontalDistanceFromSkiCenterToCoM : Double {
        get {
            // xnorth かつz vertical なスキーの中心原点の重心位置とフォールラインの水平方向ベクトルの内積
            simd_dot(currentTrueNorthZVerticalCenterOfMass.vector ,horizontalDirOfFallLine.normalized.vector)
        }
    }
    
    func receiveUWBMeasuredData(data: UWBMeasuredData,_: MPCSession){
        centerOfMassRelativeDirectionFromSki = data.realDistance
    }
    
    init(){
        
    }
    
    init(fallLineDirectionZVerticalXTrueNorth: Rotation3D, skiDirectionAbsoluteByNorth: Rotation3D, centerOfMassRelativeDirectionFromSki: Point3D, turnYawingSide: TurnYawingSide) {
        self.fallLineDirectionZVerticalXTrueNorth = fallLineDirectionZVerticalXTrueNorth
        self.skiDirectionAbsoluteByNorth = skiDirectionAbsoluteByNorth
        self.centerOfMassRelativeDirectionFromSki = centerOfMassRelativeDirectionFromSki
        self.turnYawingSide = turnYawingSide
    }
    
    
    var currentTrueNorthZVerticalCenterOfMass: Point3D {
        get{
            centerOfMassRelativeDirectionFromSki.rotated(by: skiDirectionAbsoluteByNorth)
        }
    }
    
    var fallLineVector: Vector3D{
        get {
            return vectorYInNroth.rotated(by: fallLineDirectionZVerticalXTrueNorth)
        }
    }
    
    //フォールラインの水平方向  xy 1のベクトルを掛けてもいけるけどこっちのほうが軽いのかな？
    var horizontalDirOfFallLine: Vector3D{
        get {
            Vector3D(x: fallLineVector.x, y: fallLineVector.y, z: 0)
        }
    }

    
    var turnYawingSide : TurnYawingSide = .Straight
//    // ステアリングアングル　フォールラインに対して何度のヨーイング角度をもっているか？
    // フォールライン方向水平
//    // 左右のターン　TODO: ここ間違ってる tan のところ
    var sterlingAngle : Angle2D{
        get{
            Angle2D(radians:acos(horizontalDirOfFallLine.normalized.dot(skiVector.normalized)))
        }
    }
    
    // ステアリングアングルが大きい状態で谷に重心が落とせていないほど減速する
    // tan かもしれない。　考えよう。 ターン後半だけにしないとね
    var 谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか : Double {
        sin(sterlingAngle) * -gravityHorizontalDistanceFromSkiCenterToCoM
    }
}

