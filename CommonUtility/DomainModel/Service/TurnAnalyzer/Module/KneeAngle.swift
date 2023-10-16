//
//  KneeAngle.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/11.
//

import Foundation
import Spatial


struct KneeAngle {
    //　膝関節の角度　// 膝関節の角度が最小になる回答がほしい でも前方向にしか膝は曲がらないでほしいのか？ねじれは？
    func data(bodyUWBMeasuredPoint: Point3D) -> Angle2D {
        
            var 大腿骨頭の位置: Point3D {
                get{
                    Point3D(x: bodyUWBMeasuredPoint.x, y: bodyUWBMeasuredPoint.y
//                            - 0.09
                            , z: bodyUWBMeasuredPoint.z
//                            + 0.02
                    )
                }
            }//  uwb measured data からわかる
            var 踝から大腿骨頭までの距離 :  Double {
                get{
                    
                    (大腿骨頭の位置 - くるぶし関節の位置).length}
            }
            return calculateAngle(sideA: 大腿骨の長さ.converted(to: UnitLength.meters).value, sideB: 膝下の骨の長さ.converted(to: UnitLength.meters).value, sideC: 踝から大腿骨頭までの距離)
        
    }
    // 上から与えられる順番
    let くるぶし関節の位置: Point3D
    = Point3D(x: 0, y: 
//                -0.1
              0
              , z:
//                -0.07
              0
    )//  x 横　0 y 縦　後ろはマイナス z 上はプラスこいつは設置状態と乗る人間で固定
    
    let 大腿骨の長さ : Measurement<UnitLength> = Measurement(value: 36, unit: UnitLength.centimeters)
    
    let 膝下の骨の長さ:Measurement<UnitLength> = Measurement(value: 36, unit: UnitLength.centimeters)
    
    
    // 一番目と二番目の間の角度が出てくる
    func calculateAngle(sideA: Double, sideB: Double, sideC: Double) -> Angle2D {
        // Ensure the sides can form a triangle
        if sideA + sideB > sideC && sideB + sideC > sideA && sideA + sideC > sideB {
            // Calculate the cosine of the angle using the Law of Cosines
            let cosAngle = (sideA * sideA + sideB * sideB - sideC * sideC) / (2 * sideA * sideB)
            // Use the arccosine function to find the angle in radians
            return Angle2D(radians: acos(cosAngle))
        }
        // If the sides cannot form a triangle, return nil
        return Angle2D(radians: .pi)
    }
    
}
