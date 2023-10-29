//
//  内倒.swift どれぐらい谷側に重心が移動しているのか？
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2023/09/25.
//

import Foundation
import Spatial
import simd
import WatchConnectivity
class InclineCoM : NSObject,ObservableObject,SteeringAngleFinder,WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
//        print("inactivated")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
//        print("activated")
    }
#endif
    var timeStamp: TimeInterval = Date.now.timeIntervalSince1970{
        willSet{
            lastTimeStamp = timeStamp
        }
    }
    var スキーに垂直な重心の加速度: Double = 0
    var スキーに垂直な方向の加速度掛けるmillSecond: Double = 0
    var bodySideTimeStamp : TimeInterval = Date.now.timeIntervalSince1970
    var bodySideMotionTimeStamp : TimeInterval = Date.now.timeIntervalSince1970
    var bodySideDirectionTimeStamp : TimeInterval = Date.now.timeIntervalSince1970
    var boardSideMotionTimeStamp: TimeInterval = Date.now.timeIntervalSince1970
    var boardSideDirectionTimeStamp: TimeInterval = Date.now.timeIntervalSince1970
    
    @Published var lastTimeStamp: TimeInterval = 1
    
    var timeDuration: TimeInterval {
        get{
            abs(timeStamp - lastTimeStamp)
        }
    }
    func receiveBodySide( _ bodySideTurnPhase: BodySideTurnPhase){
        self.スキーに垂直な重心の加速度 = bodySideTurnPhase.スキーに垂直方向の加速度
        self.スキーに垂直な方向の加速度掛けるmillSecond = bodySideTurnPhase.スキーに垂直な方向の加速度掛けるmillSecond
        self.bodySideTimeStamp = bodySideTurnPhase.timeStamp
        self.bodySideMotionTimeStamp = bodySideTurnPhase.deviceTimeStamp
        self.bodySideDirectionTimeStamp = bodySideTurnPhase.distanceTimeStamp
    }
    // 前向きのベクトルを設定する スマホの画面上が +y方向 (x:0,y:1,z: 0)
    let fowardVector = Vector3D.up
    // 北を絶対値x0とするフォールライン方向
    @Published var fallLineDirectionZVerticalXTrueNorth : Rotation3D = Rotation3D()
    // 北を絶対値z0とする現在のスキーの向きと姿勢
    @Published var skiDirectionAbsoluteByNorth: Rotation3D = Rotation3D()
    // スキーセンターからスキーに対して垂直な重心の距離と向き
    @Published var centerOfMassRelativeDirectionFromSki: Point3D = Point3D()
    
    @Published var diffPercentageByAngle : Double = 0
    func receiveUWBMeasuredData(data: UWBMeasuredData){
        centerOfMassRelativeDirectionFromSki = data.realDistance
        timeStamp = data.timeStamp
        boardSideDirectionTimeStamp = data.timeStamp
        exportRidingData.write(self)
//        do {
//            try WCSession.default.updateApplicationContext(["内倒度合い": gravityHorizontalDistanceFromSkiCenterToCoM])
//        } catch let error {
//            print(error)
//        }
    }
    
    func receiveDeviceMotion(motion: DeviceMotion,skiTurnPhase: SkiTurnPhase){
        self.skiDirectionAbsoluteByNorth = motion.attitude
        self.turnYawingSide = skiTurnPhase.turnYawingSide
        self.timeStamp = motion.timeStamp
        self.fallLineDirectionZVerticalXTrueNorth = skiTurnPhase.fallLine
        self.diffPercentageByAngle = skiTurnPhase.diffPercentage
        self.boardSideMotionTimeStamp = motion.timeStamp
        exportRidingData.write(self)
    }
    
    init(exportRidingData: ExportRidingData){
        self.exportRidingData = exportRidingData
//        if WCSession.isSupported() {
//            WCSession.default.delegate = self
//            WCSession.default.activate()
//        }
    }
    var exportRidingData:ExportRidingData
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
            centerOfMassRelativeDirectionFromSki.rotated(by: skiDirectionAbsoluteByNorth.inverse)
        }
    }
    
    
    //裏返しになると　zが逆になるべきだが、それってどういうことよ　簡単な式ダラわせ内の尾？
    // 初期状態を　上向きベクトルとの内積が0
    var スマホの表裏:Bool{
        get{
            Vector3D(z: 1).rotated(by: skiDirectionAbsoluteByNorth).dot(Vector3D(z:1)) > 0
        }
    }
    var fallLineVector: Vector3D{
        get {
            fowardVector.rotated(by: fallLineDirectionZVerticalXTrueNorth)
        }
    }
    
    var diffRotationFromFallLineToSkiDirection: Rotation3D{
        get{
            fallLineDirectionZVerticalXTrueNorth.inverse * skiDirectionAbsoluteByNorth
        }
    }
    
    var yを前方とした相対的なフォールライン方向から現在の板の向き: Vector3D{
        get {
            fowardVector.rotated(by: diffRotationFromFallLineToSkiDirection)
        }
    }
    
    var fallLineHorizontal: Vector3D {
        get{
            var 表裏 : Double = 0
            if (スマホの表裏){
                表裏 = -1
            } else {
                表裏 = 1
            }
            return yを前方とした相対的なフォールライン方向から現在の板の向き.scaledBy(x: 表裏,y: 1,z: 0)
        }
    }
    // xy だけz 分まわすかな
    var スマホのyを前方とした重心の位置: Point3D {
        get{
            let v = currentTrueNorthZVerticalCenterOfMass
            var 表裏 : Double = 0
            if (スマホの表裏){
                表裏 = 1
            } else {
                表裏 = -1
            }
            let skiAngles = skiDirectionAbsoluteByNorth.eulerAngles(order: .xyz).angles
            let zrad = skiAngles.z * 表裏
            let xd = v.x * cos(zrad) - v.y * sin(zrad)
            let yd = v.x * sin(zrad) + v.y * cos(zrad)
//            currentTrueNorthZVerticalCenterOfMass.rotated(by: Rotation3D(eulerAngles: EulerAngles(x: Angle2D(radians: Double), y: Angle2D, z: Angle2D(radians: zrad), order: .xyz)))
            return Point3D(x: xd * 表裏, y: yd * 表裏 , z: v.z)
        }
    }
    
    var gravityHorizontalDistanceFromSkiCenterToCoM : Measurement<UnitLength> {
        get {
            // xnorth かつz vertical なスキーの中心原点の重心位置とフォールラインの水平方向ベクトルの内積
            // 現在の前方が x1の時北に１の場合のはずこれのベクトルと
            Measurement(value: simd_dot(スマホのyを前方とした重心の位置.vector, fallLineHorizontal.normalized.vector), unit: .meters)
        }
    }
}


protocol SteeringAngleFinder:InclineCoMProtocol{
    
}
extension SteeringAngleFinder{
    
    var sterlingAngle : Angle2D{
        get{
            Angle2D(radians:
                        (fallLineDirectionZVerticalXTrueNorth.inverse * skiDirectionAbsoluteByNorth).eulerAngles(order: .xyz).angles.z
            )
        }
    }
    
    var 谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか : Double {
        sin(sterlingAngle) * gravityHorizontalDistanceFromSkiCenterToCoM.value
    }
}

extension Array where Element == InclineCoM {
    func いちターンでの内倒合計 ()-> Double{
        self.map{$0.gravityHorizontalDistanceFromSkiCenterToCoM.converted(to: .centimeters).value * $0.timeDuration}.reduce(0, +)
    }
    
    func いちターンでの谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか ()-> Double {
        self.map{$0.谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか * $0.timeDuration * 100}.reduce(.zero, +)
    }
}
