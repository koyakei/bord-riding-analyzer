//
//  ContentView.swift
//  BoardRidingAnalyzer Watch App
//
//  Created by koyanagi on 2023/10/08.
//

import SwiftUI
import WatchConnectivity
struct ContentView: View {
    @StateObject var session : SessionDelegator
    var body: some View {
        VStack {
            Text("膝の角度")
            
            Text("内倒度合い")
            Text(session.内倒.f2)
            Text("FPS")
            Text(session.lastUpdated.description)
        }
        .padding()
    }
}

