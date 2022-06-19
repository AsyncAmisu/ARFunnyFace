//
//  ContentView.swift
//  ARFunnyFace
//
//  Created by Alexander Snitko on 16.06.22.
//

import SwiftUI
import RealityKit
import ARKit

var arView: ARView!
var robot: Experience.Robot!

struct ContentView : View {
    
    @State var propId: Int = 0
        
    var body: some View {
        return ZStack(alignment: .bottom) {
            ARViewContainer(propId: $propId).edgesIgnoringSafeArea(.all)
            HStack {
                Spacer()
                Button {
                    self.propId = self.propId <= 0 ? 0 : self.propId - 1
                } label: {
                    Image("PreviousButton").clipShape(Circle())
                }
                Spacer()
                Button {
                     self.takeSnapShot()
                } label: {
                    Image("ShutterButton").clipShape(Circle())
                }
                Spacer()
                Button {
                    self.propId = self.propId >= 3 ? 3 : self.propId + 1
                } label: {
                    Image("NextButton").clipShape(Circle())
                }
                Spacer()

            }
        }
    }
    
    func takeSnapShot() {
        arView.snapshot(saveToHDR: false) { image in
            let compressedImage = UIImage(data: (image?.pngData())!)
            UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var propId: Int
    
    class ARDelegateHandler: NSObject, ARSessionDelegate {
        
        var arViewContainer: ARViewContainer
        
        init(_ control: ARViewContainer) {
            arViewContainer = control
            super.init()
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard robot != nil else { return }
            
            var faceAnchor: ARFaceAnchor?
            anchors.forEach { anchor in
                if let anchor = anchor as? ARFaceAnchor {
                    faceAnchor = anchor
                }
            }
            
            let blendShapes = faceAnchor?.blendShapes
            let eyeBlinkLeft = blendShapes?[.eyeBlinkLeft]?.floatValue
            let eyeBlinkRight = blendShapes?[.eyeBlinkRight]?.floatValue
            let browInnerUp = blendShapes?[.browInnerUp]?.floatValue
            let browLeft = blendShapes?[.browDownLeft]?.floatValue
            let browRight = blendShapes?[.browDownRight]?.floatValue
            let jawOpen = blendShapes?[.jawOpen]?.floatValue
            
            robot.eyeLidL?.orientation = simd_mul(
                simd_quatf(angle: deg2Rad(-120 + (90 * eyeBlinkLeft!)),
                           axis: [1, 0, 0]),
                simd_quatf(angle: deg2Rad((90 * browLeft!) - (30 * browInnerUp!)),
                           axis: [0, 0, 1]))
            
            robot.eyeLidR?.orientation = simd_mul(
                simd_quatf(angle: deg2Rad(-120 + (90 * eyeBlinkRight!)),
                           axis: [1, 0, 0]),
                simd_quatf(angle: deg2Rad((-90 * browRight!) - (-30 * browInnerUp!)),
                           axis: [0, 0, 1]))
            
            robot.jaw?.orientation = simd_quatf(angle: deg2Rad(-100 + (60 * jawOpen!)), axis: [1, 0, 0])
            
        }
        
        func deg2Rad(_ value: Float) -> Float {
            return value * .pi / 180
        }
        
    }
    
    func makeCoordinator() -> ARDelegateHandler {
        ARDelegateHandler(self)
    }
        
    func makeUIView(context: Context) -> ARView {
        arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        robot = nil
        
        uiView.scene.anchors.removeAll()
        let arConfiguration = ARFaceTrackingConfiguration()
        uiView.session.run(arConfiguration, options: [.resetTracking, .removeExistingAnchors])
        
        switch propId {
        case 0:
            let arAnchor = try! Experience.loadEyes()
            uiView.scene.anchors.append(arAnchor)
            break
        case 1:
            let arAnchor = try! Experience.loadGlasses()
            uiView.scene.anchors.append(arAnchor)
            break
        case 2:
            let arAnchor = try! Experience.loadMustache()
            uiView.scene.anchors.append(arAnchor)
            break
        case 3:
            let arAnchor = try! Experience.loadRobot()
            uiView.scene.anchors.append(arAnchor)
            robot = arAnchor
            break
        default:
            break
        }
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
