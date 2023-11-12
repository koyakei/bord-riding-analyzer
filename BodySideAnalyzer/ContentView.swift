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
import simd
import GLKit
struct ARViewContainer: UIViewRepresentable {
    var arView: ARView
    
    
    func makeUIView(context: Context) -> ARView {
        
        
            return arView
        }

        func updateUIView(_ uiView: ARView, context: Context) {
        }
}

struct ContentView: View {
    
    
    @StateObject var mpcManager : MPCManager
    @StateObject var mPCNIDelegateManager : MPCNIDelegateManager
    @StateObject var bodyMotionManager: BodyMotionManager
    
    @State var arContainer = ARViewContainer(arView: ARView(frame: .zero))
   
    @State var  cancellable : AnyCancellable?  = nil
    
    @State var isRecording = false
    
    func quaternionForRotationBetweenVectors(vectorA: Vector3D , vectorB: Vector3D ) -> Rotation3D  {
        let cosTheta = vectorA.dot(vectorB)
        let rotationAxis = vectorA.cross(vectorB)
        
        let vectorLengthProduct = vectorA.length * vectorB.length
        let sinTheta = rotationAxis.length / vectorLengthProduct

        let s = simd_quaternion(rotationAxis.x * sinTheta, rotationAxis.y * sinTheta, rotationAxis.z * sinTheta, cosTheta).normalized
        
        return Rotation3D(s)
    }
    
    func addSimpleMaterial() {
        // ヨーイングだけ逆にしたい
        
//        body表示垂直下()
        print("pointing")
        if let dir = mPCNIDelegateManager.uwbMeasuredData?.direction, let pose = Pose3D(arContainer.arView.cameraTransform.matrix){
            board表示(dir: dir)
            // フォールライン方向を北としてテスト表示してみる
            フォールラインから重心迄のフォールライン方向の矢印(ボード位置相対dir: dir, フォールライン方向XNoarth: Rotation3D())
            フォールラインから重心迄のフォールライン方向の矢印1(ボード位置相対dir: dir, フォールライン方向XNoarth: Rotation3D())
//            フォールラインから重心迄のフォールライン方向の矢印2(ボード位置相対dir: dir, フォールライン方向XNoarth: Rotation3D())
//            フォールラインから重心迄のフォールライン方向の矢印3(ボード位置相対dir: dir, フォールライン方向XNoarth: Rotation3D())
            print(Float(dir.length) / 2)
            print(dir)
        }
        
        
       
    }
    func test(color: UIColor, pose: Pose3D,dir: Vector3D){
        let coMEntity =
        AnchorEntity(.world(transform: pose.matrix.float4x4))
        coMEntity.addChild(ModelEntity(mesh: .generateBox(width: 0.05, height: 0.05, depth: Float(dir.length) * 2),materials: [SimpleMaterial(color: color, isMetallic: false)]))
        arContainer.arView.scene.addAnchor(coMEntity)
    }
    
    
    func 原点表示(){
        let coMEntity =
        AnchorEntity(world: arContainer.arView.cameraTransform.translation)
        coMEntity.addChild(ModelEntity(mesh: .generateSphere(radius: 0.05),materials: [SimpleMaterial(color: .green, isMetallic: false)]))
        arContainer.arView.scene.addAnchor(coMEntity)
    }
    
    
    func フォールラインから重心迄のフォールライン方向の矢印( ボード位置相対dir: Vector3D, フォールライン方向XNoarth: Rotation3D){
        let r = bodyMotionManager.bodySideTurnPhase.attitude.quaternion.simdQuatF.vector
        let r2 = SCNVector4FromGLKVector4(GLKVector4Make(r.x,r.y,r.z,r.w))
        
        let 現在のスマホのローテーションから見たフォールライン方向に現在の起動時からの相対的回転で回す行列 =
//        Rotation3D(arContainer.arView.cameraTransform.rotation.inverse) * //現在の位置に
        r2.rotation3D// 北の位置を示すクオータニオンにする　体側XNoarth から回転の逆　回す
        //　北を向いたらそこからフォールライン方向を北向き基準で回す
        let pose = boardPose(dir: ボード位置相対dir)// ボードの位置を計算
            .rotated(by: 現在のスマホのローテーションから見たフォールライン方向に現在の起動時からの相対的回転で回す行列)
        let 内倒度合い矢印 =
        AnchorEntity(.world(transform: pose.matrix.float4x4))
        // TODO 箱の向きを縦横深さのどれを長軸とするかで調整イウ
        内倒度合い矢印.addChild(ModelEntity(mesh: .generateBox(width: 0.05, height: 0.05, depth:  0.5),materials: [SimpleMaterial(color: .red, isMetallic: false)]))
        arContainer.arView.scene.addAnchor(内倒度合い矢印)
    }
    
    func フォールラインから重心迄のフォールライン方向の矢印1( ボード位置相対dir: Vector3D, フォールライン方向XNoarth: Rotation3D){
        let r = bodyMotionManager.bodySideTurnPhase.attitude.quaternion.simdQuatF.vector
        let r2 = SCNVector4FromGLKVector4(GLKVector4Make(r.x,r.y,r.z,r.w))
        let 現在のスマホのローテーションから見たフォールライン方向に現在の起動時からの相対的回転で回す行列 =
        Rotation3D(arContainer.arView.cameraTransform.rotation.inverse) * //現在の位置に
        r2.rotation3D// 北の位置を示すクオータニオンにする　体側XNoarth から回転の逆　回す 北の位置を示すクオータニオンにする　体側XNoarth から回転の逆　回す
//        * フォールライン方向XNoarth //　北を向いたらそこからフォールライン方向を北向き基準で回す
        
        let pose = boardPose(dir: ボード位置相対dir)// ボードの位置を計算
            .rotated(by: 現在のスマホのローテーションから見たフォールライン方向に現在の起動時からの相対的回転で回す行列)
        let 内倒度合い矢印 =
        AnchorEntity(.world(transform: pose.matrix.float4x4))
        // TODO 箱の向きを縦横深さのどれを長軸とするかで調整イウ
        内倒度合い矢印.addChild(ModelEntity(mesh: .generateBox(width: 0.05, height: 0.05, depth:  0.5),materials: [SimpleMaterial(color: .green, isMetallic: false)]))
        arContainer.arView.scene.addAnchor(内倒度合い矢印)
    }
    
    func フォールラインから重心迄のフォールライン方向の矢印2( ボード位置相対dir: Vector3D, フォールライン方向XNoarth: Rotation3D){
        let 現在のスマホのローテーションから見たフォールライン方向に現在の起動時からの相対的回転で回す行列 = 
        Rotation3D(arContainer.arView.cameraTransform.rotation) * //現在の位置に
        convertQuaternion(bodyMotionManager.bodySideTurnPhase.attitude.quaternion).inverse // 北の位置を示すクオータニオンにする　体側XNoarth から回転の逆　回す
//        * フォールライン方向XNoarth //　北を向いたらそこからフォールライン方向を北向き基準で回す
        
        let pose = boardPose(dir: ボード位置相対dir)// ボードの位置を計算
            .rotated(by: 現在のスマホのローテーションから見たフォールライン方向に現在の起動時からの相対的回転で回す行列)
        let 内倒度合い矢印 =
        AnchorEntity(.world(transform: pose.matrix.float4x4))
        // TODO 箱の向きを縦横深さのどれを長軸とするかで調整イウ
        内倒度合い矢印.addChild(ModelEntity(mesh: .generateBox(width: 0.05, height: 0.05, depth:  0.5),materials: [SimpleMaterial(color: .brown, isMetallic: false)]))
        arContainer.arView.scene.addAnchor(内倒度合い矢印)
    }
    
    func convertQuaternion(_ quaternion: simd_quatd) -> Rotation3D {
        // Xが横、Yが前後、Zが縦の座標軸をXが横、Yが縦、Zが前後に変換する回転行列
        let rotationMatrix = double3x3(rows: [
            double3(1, 0, 0),
            double3(0, 0, 1),
            double3(0, -1, 0)
        ])
        
        // 回転行列からクオータニオンを生成
        let rotatedQuaternion = simd_quatd(rotationMatrix)
        
        // 変換後のクオータニオンを返す
        return Rotation3D(rotatedQuaternion * quaternion)
    }
    
    func フォールラインから重心迄のフォールライン方向の矢印3( ボード位置相対dir: Vector3D, フォールライン方向XNoarth: Rotation3D){
        let 現在のスマホのローテーションから見たフォールライン方向に現在の起動時からの相対的回転で回す行列 = 
        Rotation3D(arContainer.arView.cameraTransform.rotation) * //現在の位置に
        convertQuaternion(bodyMotionManager.bodySideTurnPhase.attitude.quaternion).inverse // 北の位置を示すクオータニオンにする　体側XNoarth から回転の逆　回す
//        * フォールライン方向XNoarth //　北を向いたらそこからフォールライン方向を北向き基準で回す
        
        let pose = boardPose(dir: ボード位置相対dir)// ボードの位置を計算
            .rotated(by: 現在のスマホのローテーションから見たフォールライン方向に現在の起動時からの相対的回転で回す行列)
        let 内倒度合い矢印 =
        AnchorEntity(.world(transform: pose.matrix.float4x4))
        // TODO 箱の向きを縦横深さのどれを長軸とするかで調整イウ
        内倒度合い矢印.addChild(ModelEntity(mesh: .generateBox(width: 0.05, height: 0.05, depth:  0.5),materials: [SimpleMaterial(color: .gray, isMetallic: false)]))
        arContainer.arView.scene.addAnchor(内倒度合い矢印)
    }
    
    
    func boardPose(dir: Vector3D)-> Pose3D {
        Pose3D(position: arContainer.arView.cameraTransform.translation, rotation: arContainer.arView.cameraTransform.rotation).translated(by: dir.sceneKitVector.rotated(by: Rotation3D(arContainer.arView.cameraTransform.rotation)))
    }
    
    func board表示(dir: Vector3D){
        let pose = boardPose(dir: dir)
        let boardEntity =
        AnchorEntity(.world(transform: pose.matrix.float4x4))
        boardEntity.addChild(ModelEntity(mesh: .generateSphere(radius: 0.05),materials: [SimpleMaterial(color: .blue, isMetallic: false)]))
        arContainer.arView.scene.addAnchor(boardEntity)
    }
    
    func board表示5(dir: Vector3D){
        
        let pose =
        Pose3D(position: arContainer.arView.cameraTransform.translation, rotation: arContainer.arView.cameraTransform.rotation).translated(by: Vector3D(SIMD3<Float>(dir)).rotated(by: Rotation3D(arContainer.arView.cameraTransform.rotation).rotated(by: Rotation3D(forward: Vector3D(SIMD3<Float>(dir)), up: Vector3D(vector: [0,0,-1])).inverse)))
        let boardEntity =
        AnchorEntity(.world(transform: pose.matrix.float4x4))
        boardEntity.addChild(ModelEntity(mesh: .generateSphere(radius: 0.05),materials: [SimpleMaterial(color: .lightText, isMetallic: false)]))
        arContainer.arView.scene.addAnchor(boardEntity)
    }
    
    func board表示6(dir: Vector3D){
        
        let pose =
        Pose3D(position: arContainer.arView.cameraTransform.translation, rotation: arContainer.arView.cameraTransform.rotation).translated(by: Vector3D(SIMD3<Float>(dir)).rotated(by: Rotation3D(forward: Vector3D(SIMD3<Float>(dir)), up: Vector3D(vector: [0,0,-1])).rotated(by: Rotation3D(arContainer.arView.cameraTransform.rotation.inverse))))
        let boardEntity =
        AnchorEntity(.world(transform: pose.matrix.float4x4))
        boardEntity.addChild(ModelEntity(mesh: .generateSphere(radius: 0.05),materials: [SimpleMaterial(color: .gray, isMetallic: false)]))
        arContainer.arView.scene.addAnchor(boardEntity)
    }
    
    func board表示7(dir: Vector3D){
        let pose =
        Pose3D(position: arContainer.arView.cameraTransform.translation, rotation: arContainer.arView.cameraTransform.rotation).translated(by: Vector3D(SIMD3<Float>(dir)).rotated(by: Rotation3D(forward: Vector3D(SIMD3<Float>(dir)), up: Vector3D(vector: [-1,0,0]))))
        let boardEntity =
        AnchorEntity(.world(transform: pose.matrix.float4x4))
        boardEntity.addChild(ModelEntity(mesh: .generateSphere(radius: 0.05),materials: [SimpleMaterial(color: .darkText, isMetallic: false)]))
        arContainer.arView.scene.addAnchor(boardEntity)
    }
    
    func board表示2(dir: Vector3D){
        let pose =
        Pose3D(position: arContainer.arView.cameraTransform.translation, rotation: arContainer.arView.cameraTransform.rotation).translated(by: Vector3D(SIMD3<Float>(dir)).rotated(by: Rotation3D(arContainer.arView.cameraTransform.rotation)))
        let boardEntity =
        AnchorEntity(.world(transform: pose.matrix.float4x4))
        boardEntity.addChild(ModelEntity(mesh: .generateSphere(radius: 0.05),materials: [SimpleMaterial(color: .cyan, isMetallic: false)]))
        arContainer.arView.scene.addAnchor(boardEntity)
    }
    
    func board表示3(dir: Vector3D){
        let rot = Rotation3D(arContainer.arView.cameraTransform.rotation)
        
        
        let rot2 = Rotation3D(eulerAngles:
                                EulerAngles(x: -Angle2D(radians: -rot.eulerAngles(order: .xyz).angles.x), y: -Angle2D(radians: -rot.eulerAngles(order: .xyz).angles.y), z: Angle2D(radians: rot.eulerAngles(order: .xyz).angles.z), order: EulerAngles.Order.xyz))
        let pose =
        Pose3D(position: arContainer.arView.cameraTransform.translation, rotation: arContainer.arView.cameraTransform.rotation).translated(by: Vector3D(SIMD3<Float>(dir)).rotated(by: rot2))
        let boardEntity =
        AnchorEntity(.world(transform: pose.matrix.float4x4))
        boardEntity.addChild(ModelEntity(mesh: .generateSphere(radius: 0.05),materials: [SimpleMaterial(color: .black, isMetallic: false)]))
        arContainer.arView.scene.addAnchor(boardEntity)
    }
    
    func board表示4(dir: Vector3D){
        let rot = Rotation3D(arContainer.arView.cameraTransform.rotation)
        
        
        let rot2 = Rotation3D(eulerAngles:
                                EulerAngles(x: Angle2D(radians: rot.eulerAngles(order: .xyz).angles.x), y: -Angle2D(radians: rot.eulerAngles(order: .xyz).angles.y), z: Angle2D(radians: rot.eulerAngles(order: .xyz).angles.z), order: EulerAngles.Order.xyz)).inverse
        let pose =
        Pose3D(position: arContainer.arView.cameraTransform.translation, rotation: arContainer.arView.cameraTransform.rotation).translated(by: Vector3D(SIMD3<Float>(dir)).rotated(by: rot2))
        let boardEntity =
        AnchorEntity(.world(transform: pose.matrix.float4x4))
        boardEntity.addChild(ModelEntity(mesh: .generateSphere(radius: 0.05),materials: [SimpleMaterial(color: .brown, isMetallic: false)]))
        arContainer.arView.scene.addAnchor(boardEntity)
    }
    
    func body表示垂直下(){
        let pose =
        Pose3D(position: arContainer.arView.cameraTransform.translation, rotation: arContainer.arView.cameraTransform.rotation).translated(by: Vector3D(SIMD3<Float>(0,0,-0.5)).rotated(by: Rotation3D(quaternion: arContainer.arView.cameraTransform.rotation)))
        let boardEntity =
        AnchorEntity(.world(transform: pose.matrix.float4x4))
        boardEntity.addChild(ModelEntity(mesh: .generateSphere(radius: 0.05),materials: [SimpleMaterial(color: .lightText, isMetallic: false)]))
        arContainer.arView.scene.addAnchor(boardEntity)
    }
    
    var body: some View {
        arContainer
            .overlay(
                Button(action: {
                    if isRecording {
                        self.cancellable = Timer.publish(every: 2, on: .main, in: .default)
                            .autoconnect()
                            .sink { _ in
//                                addSimpleMaterial()
                                addSimpleMaterial()
                            }
                        isRecording = false
                    } else {
                        cancellable?.cancel()
                        isRecording = true
                    }
                }) {
                    Text("start objc")
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
            Text(mPCNIDelegateManager.uwbMeasuredData?.realDistance.realPoint3DByCentimeter.description ?? "nasi")
            Button("start uwb"){
                mPCNIDelegateManager.shareMyDiscoveryToken()
            }
        }.onAppear(perform: {
            mpcManager.startup()
            mPCNIDelegateManager.startup()
            let yfw = Vector3D(vector: [0, 0, -1]).rotated(by: bodyMotionManager.bodySideTurnPhase.attitude)
            let anchorEntity2 =
            AnchorEntity(world: arContainer.arView.cameraTransform.translation +
                         SIMD3<Float>( Float(yfw.vector.x), Float(yfw.vector.z), Float(yfw.vector.y))
            )
            let modelEntity2 = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .gray, isMetallic: false)])
            anchorEntity2.addChild(modelEntity2)
            // 1G で下10cm かな？
            arContainer.arView.scene.addAnchor(anchorEntity2)
        })
//        VStack {
//            TextField("プレースホルダー", text: $mpcManager.message)
//            Button("sendm"){
//                mpcManager.sendMessage()
//            }
//            Text(mPCNIDelegateManager.uwbMeasuredData?.realDistance.realPoint3DByCentimeter.description ?? "nasi")
//            Button("start uwb"){
//                mPCNIDelegateManager.shareMyDiscoveryToken()
//            }
//            Button("start motion record"){
//                bodyMotionManager.start()
//            }
//            HStack{
//                Text("スキー方向に掛かる力")
//                Text(
//                    bodyMotionManager.bodySideTurnPhase.スキーに垂直方向の加速度.f2)
//            }
//            HStack{
//                Text("userAcceleration")
//                Text(
//                    bodyMotionManager.bodySideTurnPhase.userAcceleration.f2)
//            }
//            
//            HStack{
//                Text("重力")
//                Text(
//                    bodyMotionManager.bodySideTurnPhase.gravity.f2)
//            }
//            
//            HStack{
//                Text("重力 + ac")
//                Text(
//                    (bodyMotionManager.bodySideTurnPhase.gravity  + bodyMotionManager.bodySideTurnPhase.userAcceleration).f2)
//            }
//            
//            HStack{
//                Text("zがどれだけ斜め")
//                Text(bodyMotionManager.bodySideTurnPhase.zがどれだけ斜め.f2)
//            }
//            HStack{
//                Text("正規化された距離")
//                Text(bodyMotionManager.bodySideTurnPhase.direction.normalized.f2)
//            }
//            
//        }.onAppear(perform: {
//            mpcManager.startup()
//            mPCNIDelegateManager.startup()
//        })
    }
}

extension simd_double4x4 {
    var float4x4 : float4x4 {
        get {
            let doubleMatrix = self
            return simd.float4x4(
                float4(Float(doubleMatrix.columns.0.x), Float(doubleMatrix.columns.0.y), Float(doubleMatrix.columns.0.z), Float(doubleMatrix.columns.0.w)),
                float4(Float(doubleMatrix.columns.1.x), Float(doubleMatrix.columns.1.y), Float(doubleMatrix.columns.1.z), Float(doubleMatrix.columns.1.w)),
                float4(Float(doubleMatrix.columns.2.x), Float(doubleMatrix.columns.2.y), Float(doubleMatrix.columns.2.z), Float(doubleMatrix.columns.2.w)),
                float4(Float(doubleMatrix.columns.3.x), Float(doubleMatrix.columns.3.y), Float(doubleMatrix.columns.3.z), Float(doubleMatrix.columns.3.w))
            )
        }
    }
}
