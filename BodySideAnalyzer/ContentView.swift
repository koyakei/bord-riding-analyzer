//
//  ContentView.swift
//  BodySideAnalyzer
//
//  Created by koyanagi on 2023/10/08.
//
import RealityKit
import SwiftUI
import ARKit
import Spatial
import Combine

struct ContentView: View {
    @StateObject var mpcManager : MPCManager
    @StateObject var mPCNIDelegateManager : MPCNIDelegateManager
    @StateObject var bodyMotionManager: BodyMotionManager
    @State var arContainer = ARViewContainer(arView: ARView(frame: .zero))
   
    @State var  cancellable : AnyCancellable?  = nil
    
    @State var isRecording = false
    var body: some View {
        arContainer
            .overlay(
                Button(action: {
                    if isRecording {
                        self.cancellable = Timer.publish(every: 2, on: .main, in: .default)
                            .autoconnect()
                            .sink { _ in
//                                addSimpleMaterial()
                                arContainer.addSimpleMaterial()
                            }
                        isRecording = false
                    } else {
                        cancellable?.cancel()
                        isRecording = true
                    }
                }) {
                    Text(Point3D(arContainer.arView.cameraTransform.translation).description)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                    .position(x: 70, y: 0) // Adjust the button's position as needed
            )
        HStack{
            Button("start"){
                bodyMotionManager.start()
            }
        }
    }
    
}
struct ARViewContainer: UIViewRepresentable {
    var arView: ARView
    func addSimpleMaterial() {
        // Create an entity with the SimpleMaterial
        let anchorEntity2 =
        AnchorEntity(world: arView.cameraTransform.translation)
        let modelEntity2 = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .blue, isMetallic: false)])
        anchorEntity2.addChild(modelEntity2)
        // 1G で下10cm かな？
        arView.scene.addAnchor(anchorEntity2)
    }
    
    func makeUIView(context: Context) -> ARView {
            return arView
        }

        func updateUIView(_ uiView: ARView, context: Context) {
        }
}

struct SecondPage: View {
    
    @StateObject var mpcManager : MPCManager
    @StateObject var mPCNIDelegateManager : MPCNIDelegateManager
    @StateObject var bodyMotionManager: BodyMotionManager
    var body: some View {
        VStack {
            TextField("プレースホルダー", text: $mpcManager.message)
            Button("sendm"){
                mpcManager.sendMessage()
            }
            Text(mPCNIDelegateManager.uwbMeasuredData?.realDistance.realPoint3DByCentimeter.description ?? "nasi")
            Button("start uwb"){
                mPCNIDelegateManager.shareMyDiscoveryToken()
            }
            Button("start motion record"){
                bodyMotionManager.start()
            }
            HStack{
                Text("スキー方向に掛かる力")
                Text(
                    bodyMotionManager.bodySideTurnPhase.スキーに垂直方向の加速度.f2)
            }
            HStack{
                Text("userAcceleration")
                Text(
                    bodyMotionManager.bodySideTurnPhase.userAcceleration.f2)
            }
            
            HStack{
                Text("重力")
                Text(
                    bodyMotionManager.bodySideTurnPhase.gravity.f2)
            }
            
            HStack{
                Text("重力 + ac")
                Text(
                    (bodyMotionManager.bodySideTurnPhase.gravity  + bodyMotionManager.bodySideTurnPhase.userAcceleration).f2)
            }
            
            HStack{
                Text("zがどれだけ斜め")
                Text(bodyMotionManager.bodySideTurnPhase.zがどれだけ斜め.f2)
            }
            HStack{
                Text("正規化された距離")
                Text(bodyMotionManager.bodySideTurnPhase.direction.normalized.f2)
            }
            
        }.onAppear(perform: {
            mpcManager.startup()
            mPCNIDelegateManager.startup()
        })
    }
}
