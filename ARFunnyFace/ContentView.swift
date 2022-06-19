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
                    self.propId = self.propId >= 2 ? 2 : self.propId + 1
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
        
    func makeUIView(context: Context) -> ARView {
        arView = ARView(frame: .zero)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
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
