//
//  NIDelegateManager.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/08.
//

import Foundation
import NearbyInteraction
import MultipeerConnectivity
#if canImport(AudioToolbox)
import AudioToolbox
#endif

protocol UwbMeasuredMutatingDelegate {
    mutating func measured( uwbMeasuredData: UWBMeasuredData)
}
class MPCNIDelegateManager :NSObject, NISessionDelegate ,ObservableObject{
    
    enum DistanceDirectionState {
        case closeUpInFOV, notCloseUpInFOV, outOfFOV, unknown
    }
    
    // MARK: - Class variables
    let session: NISession = NISession()
    var peerDiscoveryToken: NIDiscoveryToken?
    var currentDistanceDirectionState: DistanceDirectionState = .unknown
    var mpc: MPCSession
    let connectedPeer: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    var sharedTokenWithPeer = false
    var peerDisplayName: String?
    var centerInformationLabel : String?
    var uwbMeasuredHandler : [( (UWBMeasuredData , MPCSession) -> Void)] = []
    var uwbMeasuredMutatingDelegate :UwbMeasuredMutatingDelegate?
    @Published var uwbMeasuredData : UWBMeasuredData? = nil{
        didSet {
            if let uwbMeasuredData = uwbMeasuredData {
                uwbMeasuredHandler.map {
                    handler in
                    handler( uwbMeasuredData, self.mpc)
                }
                uwbMeasuredMutatingDelegate?.measured(uwbMeasuredData: uwbMeasuredData)
            }else if uwbMeasuredData == nil {
                playNotificationSound()
            }
        }
    }
    
    var uwbMeasuredDatas : [UWBMeasuredData] = []{
        didSet{
            if uwbMeasuredDatas.count > 1500 {
                uwbMeasuredDatas.removeFirst(uwbMeasuredDatas.count - 1500)
            }
        }
    }
    
    var fps :Int{
        get{
            if let newestTimestamp  = uwbMeasuredDatas.last?.timeStamp{
                uwbMeasuredDatas.filter {
                    $0.timeStamp > (newestTimestamp - 1)
                }.count
            } else {
                0
            }
            
        }
    }
    
    func playNotificationSound() {
        let soundIdRing:SystemSoundID = 1000  // new-mail.caf
        AudioServicesPlaySystemSound(soundIdRing)
    }
    
    init(mpc: MPCSession){
        self.mpc = mpc
        super.init()
        session.delegate = self
        mpc.peerDataReciever.append(dataReceivedHandler)
        startup()
    }
    
    func startup() {
        // Because the session is new, reset the token-shared flag.
        sharedTokenWithPeer = false
        shareMyDiscoveryToken()
        
    }
    
    // MARK: - `NISessionDelegate`.
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        nearbyObjects.map{
            object in
            if let data :UWBMeasuredData = try? UWBMeasuredData(niObject: object){
                self.uwbMeasuredData = data
                uwbMeasuredDatas.append(data)
            } else {
                self.uwbMeasuredData = nil
            }
        }
    }
    
    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        guard let peerToken = peerDiscoveryToken else {
            fatalError("don't have peer token")
        }
        // Find the right peer.
        let peerObj = nearbyObjects.first { (obj) -> Bool in
            return obj.discoveryToken == peerToken
        }
        
        if peerObj == nil {
            return
        }
        
        currentDistanceDirectionState = .unknown
        
        switch reason {
        case .peerEnded:
            // The peer token is no longer valid.
            peerDiscoveryToken = nil
            
            // The peer stopped communicating, so invalidate the session because
            // it's finished.
            session.invalidate()
            
            // Restart the sequence to see if the peer comes back.
            startup()
            
            // Update the app's display.
            updateInformationLabel(description: "Peer Ended")
        case .timeout:
            
            // The peer timed out, but the session is valid.
            // If the configuration is valid, run the session again.
            if let config = session.configuration {
                session.run(config)
            }
            updateInformationLabel(description: "Peer Timeout")
        default:
            fatalError("Unknown and unhandled NINearbyObject.RemovalReason")
        }
    }
    
    func sessionWasSuspended(_ session: NISession) {
        currentDistanceDirectionState = .unknown
        updateInformationLabel(description: "Session suspended")
    }
    
    func sessionSuspensionEnded(_ session: NISession) {
        // Session suspension ended. The session can now be run again.
        if let config = self.session.configuration {
            session.run(config)
        } else {
            // Create a valid configuration.
            startup()
        }
        
        centerInformationLabel = peerDisplayName
    }
    
    func session(_ session: NISession, didInvalidateWith error: Error) {
        
        
        // Recreate a valid session.
        startup()
    }
    
    func disconnectedFromPeer() {
        let peer = mpc.mcSession.myPeerID
        if connectedPeer == peer {
            sharedTokenWithPeer = false
        }
    }
    
    func dataReceivedHandler(data: Data, peer: MCPeerID) {
        if let discoveryToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) {
            peerDidShareDiscoveryToken(peer: peer, token: discoveryToken)
        }
    }
    
    func shareMyDiscoveryToken() {
        if let encodedData = try?  NSKeyedArchiver.archivedData(withRootObject: session.discoveryToken, requiringSecureCoding: true) {
            mpc.sendDataToAllPeers(data: encodedData)
            sharedTokenWithPeer = true
        }
    }
    
    func peerDidShareDiscoveryToken(peer: MCPeerID, token: NIDiscoveryToken) {
        // Create a configuration.
        peerDiscoveryToken = token
        let config = NINearbyPeerConfiguration(peerToken: token)
        // Run the session.
        session.run(config)
    }
    
    
    func getDistanceDirectionState(from nearbyObject: NINearbyObject) -> DistanceDirectionState {
        if nearbyObject.distance == nil && nearbyObject.direction == nil {
            return .unknown
        }
        return .outOfFOV
    }
    
    private func animate(from currentState: DistanceDirectionState, to nextState: DistanceDirectionState, with peer: NINearbyObject) {
        
    }
    
    func updateVisualization(from currentState: DistanceDirectionState, to nextState: DistanceDirectionState, with peer: NINearbyObject) {
        // Invoke haptics on "peekaboo" or on the first measurement.
        if currentState == .notCloseUpInFOV && nextState == .closeUpInFOV || currentState == .unknown {
        }
        
        // Animate into the next visuals.
        UIView.animate(withDuration: 0.3, animations: {
            self.animate(from: currentState, to: nextState, with: peer)
        })
    }
    
    func updateInformationLabel(description: String) {
        self.centerInformationLabel = description
    }
}
