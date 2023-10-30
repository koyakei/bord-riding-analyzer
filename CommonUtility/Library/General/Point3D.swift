//
//  RiderDataForWatch.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2023/09/23.
//

import Foundation
import simd
import Spatial

extension Point3D {
    var realDistanceX: Measurement<UnitLength> {
        get{
            Measurement(value: x, unit: .meters)
        }
    }
    
    var realDistanceY: Measurement<UnitLength> {
        get{
            Measurement(value: y, unit: .meters)
        }
    }
    
    var realDistanceZ: Measurement<UnitLength> {
        get{
            Measurement(value: z, unit: .meters)
        }
    }
    
    var realPoint3DByCentimeter: String {
        get{
            return "\(cmcv(distance: self.realDistanceX)),\(cmcv(distance: self.realDistanceY)),\(cmcv(distance: self.realDistanceZ))"
        }
    }
    
    func cmcv(distance: Measurement<UnitLength>) ->Int{
        let d = distance.converted(to: .centimeters).value
        guard !(d.isNaN || d.isInfinite) else {
            return Int(0) // or do some error handling
        }
        return Int(round(distance.converted(to: .centimeters).value))
    }
}

