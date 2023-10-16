//
//  MPCManager.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/08.
//

import Foundation
import MultipeerConnectivity
import NearbyInteraction

struct MPCSessionConstants {
    static let kKeyIdentity: String = "identity"
}

class MPCManager: ObservableObject {
    enum DistanceDirectionState {
        case closeUpInFOV, notCloseUpInFOV, outOfFOV, unknown
    }
    @Published var peerDisplayName :String = "no"
    @Published var connectedPeer: MCPeerID?
    var mpc: MPCSession = MPCSession()
    @Published var message : String = "no"
    var currentDistanceDirectionState: DistanceDirectionState = .unknown
    
    func updateInformationLabel(description: String) {
        message = description
    }
    func startupMPC() {
        mpc.peerConnectedHandler.append( connectedToPeer)
        mpc.peerDataReciever.append( dataReceivedHandler)
        mpc.peerDisconnectedHandler.append(disconnectedFromPeer)
        mpc.invalidate()
        mpc.start()
    }
    
    func sendMessage(){
        if let data: Data = try? message.data(using: .utf8){
            mpc.sendDataToAllPeers(data: data)
        }
    }
    
    func dataReceivedHandler(data: Data, peer: MCPeerID) {
        if let message = String(data: data, encoding: .utf8) {
            self.message = message
            
        }
    }
    
    func connectedToPeer(peer: MCPeerID) {
        if connectedPeer != nil {
            print("Already connected to a peer.")
        }
        print("Already connected to a peer.")
        connectedPeer = peer
        peerDisplayName = peer.displayName
    }
    
    func disconnectedFromPeer(peer: MCPeerID) {
        print("disconecct")
        if connectedPeer == peer {
            connectedPeer = nil
        }
        mpc.start()
    }
    func startup() {
        
        // If `connectedPeer` exists, share the discovery token, if needed.
        if connectedPeer == nil {
            updateInformationLabel(description: "Discovering Peer ...")
            startupMPC()
            // Set the display state.
            currentDistanceDirectionState = .unknown
        }
    }
}
