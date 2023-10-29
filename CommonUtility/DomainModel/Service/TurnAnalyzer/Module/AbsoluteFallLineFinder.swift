//
//  AbsoluteFallLineFinder.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/09.
//

import Foundation
import CoreMotion
import simd
import Spatial

struct AbsoluteFallLineFinder {
    struct QuaternionRecord: QuaternionFProtocol {
        var simd_quatd: simd_quatd
        var timeStamp: TimeInterval
    }
    var absoluteAttitudeRecords: [QuaternionRecord] = []
    var yawingMovingAverage: Rotation3D = Rotation3D()
    mutating func handle(quaternion: simd_quatd, timeStampSince1970: TimeInterval, yawingPeriod: TimeInterval) -> Rotation3D {
        if absoluteAttitudeRecords.count > 500{
            absoluteAttitudeRecords.removeFirst()
        }
        absoluteAttitudeRecords.append(QuaternionRecord.init(simd_quatd: quaternion, timeStamp: timeStampSince1970))
        yawingMovingAverage = Rotation3D(absoluteAttitudeRecords.yawYawingMovingAverage(yawingPeriod: yawingPeriod))
        return yawingMovingAverage
    }
}

protocol TimeStamp {
    var timeStamp : TimeInterval {get}
}

protocol QuaternionFProtocol : TimeStamp {
    var simd_quatd : simd_quatd {get}
}

extension Collection where Element: QuaternionFProtocol {
    func yawYawingMovingAverage(yawingPeriod: TimeInterval) -> simd_quatd {
        self.filterByBeforeMilleSecondsFromNow(timeInterval: yawingPeriod).map {
            $0.simd_quatd}.reduce(simd_quatd(ix: .zero,iy: .zero,iz: .zero,r: .zero),+).normalized
    }
}

// 時刻　向き　加速度　rotation_rate
extension Collection where Element: TimeStamp {
    func filterByBeforeMilleSecondsFromNow(
        timeInterval: TimeInterval) -> [Element] {
            self.filter {
                $0.timeStamp > ($0.timeStamp - timeInterval)
            }
        }
}
