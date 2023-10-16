import Foundation
import NearbyInteraction
import Spatial

extension NINearbyObject{
    var locationVector3D : Vector3D?{
        get {
            if let dir = self.direction , let dis = self.distance{
                Vector3D(dir).uniformlyScaled(by: Double(dis))
            } else {
                nil
            }
        }
    }
}
