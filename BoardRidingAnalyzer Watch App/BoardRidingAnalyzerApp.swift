//
//  BoardRidingAnalyzerApp.swift
//  BoardRidingAnalyzer Watch App
//
//  Created by koyanagi on 2023/10/08.
//

import SwiftUI
import WatchConnectivity
@main
struct BoardRidingAnalyzer_Watch_AppApp: App {
    
    let session = SessionDelegator()
    var body: some Scene {
        WindowGroup {
            ContentView(session: session)
        }
    }
}

class SessionDelegator: NSObject, WCSessionDelegate ,ObservableObject{
    
    @Published var 内倒 : Double = 0
    @State var 垂直圧力: Double = 0
    // Monitor WCSession activation state changes.
    //
    @State var lastUpdated: TimeInterval = Date.now.timeIntervalSince1970
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    // Monitor WCSession reachability state changes.
    //
    func sessionReachabilityDidChange(_ session: WCSession) {
    }
    
    // Did receive an app context.
    //
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        if let 内倒 = applicationContext["内倒度合い"] as? Double {
            self.内倒 = 内倒
        } else if let 内倒 = applicationContext["垂直圧力"] as? Double {
            self.内倒 = 内倒
        }
        lastUpdated = Date.now.timeIntervalSince1970
    }
    
    // Did receive a message, and the peer doesn't need a response.
    //
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
       
    }
    
    // Did receive a message, and the peer needs a response.
    //
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
    }
    
    // Did receive a piece of message data, and the peer doesn't need a response.
    //
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
    }
    
    // Did receive a piece of message data, and the peer needs a response.
    //
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
    }
    
    // Did receive a piece of userInfo.
    //
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
       
    }
    
    // Did finish sending a piece of userInfo.
    //
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
    }
    
    // Did receive a file.
    //
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
       
    }
    
    // Did finish a file transfer.
    //
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        
    }
    
    // WCSessionDelegate methods for iOS only.
    //
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
      
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Activate the new session after having switched to a new watch.
        session.activate()
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    #endif
    
}
