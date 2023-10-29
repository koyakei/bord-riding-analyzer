//
//  UMBMeasuredData.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2023/10/04.
//

import Foundation
import Spatial
import NearbyInteraction

enum MyError: Error {
    case negativeValue
}

protocol UWBMeasuredDataProtocol : TimeStamp{
    var direction: Vector3D {get }
}

extension UWBMeasuredDataProtocol {
    var distance : Measurement<UnitLength> {
        get {
            Measurement(value: direction.length, unit: UnitLength.meters)
        }
    }
    
    var realDistance: Point3D {
        get{
            return Point3D(direction)
        }
    }
}
extension Vector3D {
    var f2: String {
        get{
            return "\(self.x.f2),\(self.y.f2),\(self.z.f2)"
        }
    }
}
struct UWBMeasuredData: Codable ,UWBMeasuredDataProtocol{
    let direction: Vector3D
    let timeStamp: TimeInterval
    
    init(niObject: NINearbyObject) throws{
        if let locationVector3D = niObject.locationVector3D {
            self.timeStamp = Date.now.timeIntervalSince1970
            self.direction = locationVector3D
        } else {
            throw MyError.negativeValue
        }
    }
   
}
