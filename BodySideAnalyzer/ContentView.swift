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
struct ContentView: View {
    @StateObject var mpcManager : MPCManager
    @StateObject var mPCNIDelegateManager : MPCNIDelegateManager
    @StateObject var bodyMotionManager: BodyMotionManager
    
    @State private var arView: ARView = ARView(frame: .zero)
    var body: some View {
        ARViewContainer(arView: $arView)
            .overlay(
                Button(action: {
                    addSimpleMaterial()
                }) {
                    Text("Add SimpleMaterial")
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
    
    func addSimpleMaterial() {
        let material = SimpleMaterial(color: .green, roughness: 0.15, isMetallic: true)
        let mesh = MeshResource.generateBox(size: 0.2, cornerRadius: 0.005)
        // Create an entity with the SimpleMaterial
        let boxEntity = ModelEntity(mesh: mesh, materials: [material])
    
        boxEntity.position = SIMD3<Float>(x: 0 , y: 0.0, z: 0.0)
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        // Add the entity to the ARView
        print("btn")
        anchor.children.append(boxEntity)
        arView.scene.addAnchor(anchor)
        // Get the tap location in the ARView
//        let tapLocation = arView.center
//        
//        // Perform a hit-test to find the position in the real world
//        if let result = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal).first {
//            let position = result.worldTransform
//            
//            // Create a SimpleMaterial
//            let material = SimpleMaterial(color: .green, isMetallic: false)
//            
//            // Create an entity with the SimpleMaterial
//            let boxEntity = ModelEntity(
//                mesh: .generateBox(size: 0.1),
//                materials: [material]
//            )
//            guard let v = Pose3D(position)?.position.vector else{ return}
//            boxEntity.position = SIMD3<Float>(x: Float(v.x) , y: Float(v.y), z: Float(v.z))
//            let anchor = AnchorEntity()
//            // Add the entity to the ARView
//            anchor.children.append(boxEntity)
//            arView.scene.addAnchor(anchor)
//        }
    }
}


struct ARViewContainer: UIViewRepresentable {
    @Binding var arView: ARView
    func markSphere(){
        
    }
    
    func makeUIView(context: Context) -> ARView {
        
        // Create a cube model
        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .blue, roughness: 0.15, isMetallic: true)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.position = SIMD3<Float>(x: 0.1 , y: 0.1, z: 0.5)
        // Create horizontal plane anchor for the content
        print("sda")
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
//        let a2 = AnchorEntity(.plane(.vertical, classification: .any, minimumBounds: SIMD2<Float>(0.5, 0.5)))
//        let a3 = AnchorEntity(.plane(.horizontal, classification: .seat, minimumBounds: SIMD2<Float>(0.1, 0.1)))
//        let a4 = AnchorEntity(.plane(.any, classification: .any, minimumBounds: SIMD2<Float>(1, 0)))
        
//        a2.children.append(model)
//        a3.children.append(model)
//        a4.children.append(model)
        anchor.children.append(model)
        // Add the horizontal plane anchor to the scene
        arView.scene.anchors.append(anchor)
//        arView.scene.anchors.append(a2)
//        arView.scene.anchors.append(a3)
//        arView.scene.anchors.append(a4)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
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
