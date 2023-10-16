//
//  MPCSession.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/08.
//

import Foundation
import MultipeerConnectivity

class MPCSession: NSObject,ObservableObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    var peerDataReciever: [((Data, MCPeerID) -> Void)] = []
    var peerConnectedHandler: [((MCPeerID) -> Void)] = []
    var peerDisconnectedHandler: [((MCPeerID) -> Void)] = []
    private let serviceType: String = "your-service"
    let mcSession: MCSession
    private let localPeerID = MCPeerID(displayName: UIDevice.current.name)
    private let mcAdvertiser: MCNearbyServiceAdvertiser
    private let mcBrowser: MCNearbyServiceBrowser
    private let identityString: String = "com.example.apple-samplecode.peekaboo-nearbyinteraction"
    private let maxNumPeers: Int = 10
    override init() {
        mcSession = MCSession(peer: localPeerID, securityIdentity: nil, encryptionPreference: .none)
        mcAdvertiser = MCNearbyServiceAdvertiser(peer: localPeerID,
                                                 discoveryInfo: nil,
                                                 serviceType: serviceType)
        mcBrowser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: serviceType)

        super.init()
        mcSession.delegate = self
        mcAdvertiser.delegate = self
        mcBrowser.delegate = self
    }

    // MARK: - `MPCSession` public methods.
    func start() {
        mcAdvertiser.startAdvertisingPeer()
        mcBrowser.startBrowsingForPeers()
    }
    
    func stop(){
        suspend()
        invalidate()
    }

    func suspend() {
        mcAdvertiser.stopAdvertisingPeer()
        mcBrowser.stopBrowsingForPeers()
    }

    func invalidate() {
        suspend()
        mcSession.disconnect()
    }

    func sendDataToAllPeers(data: Data) {
        sendData(data: data, peers: mcSession.connectedPeers, mode: .reliable)
    }

    func sendData(data: Data, peers: [MCPeerID], mode: MCSessionSendDataMode) {
        if peers.count > 0{
            do {
                try mcSession.send(data, toPeers: peers,with: .unreliable)
            } catch let error {
                NSLog("Error sending data: \(error)")
            }
        }
    }

    // MARK: - `MPCSession` private methods.
    private func peerConnected(peerID: MCPeerID) {
        
           
        peerConnectedHandler.map { handler in
            DispatchQueue.main.async {
                handler(peerID)
            }
        }
        if mcSession.connectedPeers.count == maxNumPeers {
            self.suspend()
        }
    }

    private func peerDisconnected(peerID: MCPeerID) {
        peerDisconnectedHandler.map {handler in
            DispatchQueue.main.async {
                handler(peerID)
            }
        }

        if mcSession.connectedPeers.count < maxNumPeers {
            self.start()
        }
    }

    // MARK: - `MCSessionDelegate`.
    internal func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            peerConnected(peerID: peerID)
        case .notConnected:
            peerDisconnected(peerID: peerID)
        case .connecting:
            break
        @unknown default:
            print("Unhandled MCSessionState")
        }
    }

    internal func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        peerDataReciever.map { handler in
            DispatchQueue.main.async {
                handler(data, peerID)
            }
        }
    }

    internal func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // The sample app intentional omits this implementation.
    }

    internal func session(_ session: MCSession,
                          didStartReceivingResourceWithName resourceName: String,
                          fromPeer peerID: MCPeerID,
                          with progress: Progress) {
        // The sample app intentional omits this implementation.
    }

    internal func session(_ session: MCSession,
                          didFinishReceivingResourceWithName resourceName: String,
                          fromPeer peerID: MCPeerID,
                          at localURL: URL?,
                          withError error: Error?) {
        // The sample app intentional omits this implementation.
    }

    // MARK: - `MCNearbyServiceBrowserDelegate`.
    internal func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
//        guard let identityValue = info?[MPCSessionConstants.kKeyIdentity] else {
//            return
//        }
//        if identityValue == identityString && mcSession.connectedPeers.count < maxNumPeers {
            browser.invitePeer(peerID, to: mcSession, withContext: nil, timeout: 1000)
//        }
    }

    internal func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // The sample app intentional omits this implementation.
    }

    // MARK: - `MCNearbyServiceAdvertiserDelegate`.
    internal func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                             didReceiveInvitationFromPeer peerID: MCPeerID,
                             withContext context: Data?,
                             invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Accept the invitation only if the number of peers is less than the maximum.
//        if self.mcSession.connectedPeers.count < maxNumPeers {
            invitationHandler(true, mcSession)
//        }
    }
}
