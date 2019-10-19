import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    // TODO: Store a global set of planet positions, to be parsed and used to update the planet nodes
    
    var curr_time = 0
    var nodePositions: [String : SCNVector3] = [:]
    var nodeAngles : [String: Double] = ["moon": 0]
    var refPositions : [String: SCNVector3] = [:]

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/GameScene.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
//        let configuration = ARImageTrackingConfiguration()
        
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "Photos", bundle: Bundle.main) else {
            print("No images available")
            return
        }

        configuration.detectionImages = trackedImages
        configuration.maximumNumberOfTrackedImages = 5
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
        
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0)
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            planeNode.name = imageAnchor.name! + "_plane"

            let planetScene = SCNScene(named: "art.scnassets/ship_sphere.scn")!
            var planetNode: SCNNode?

            if imageAnchor.name! == "sun" {
                planetNode = planetScene.rootNode.childNodes[1]
            } else if imageAnchor.name! == "moon" {
                planetNode = planetScene.rootNode.childNodes[2]
                // TODO: Need to add physics and have it interact with sun
            }
            planetNode!.name = imageAnchor.name!
            planetNode!.position = SCNVector3Zero
            planetNode!.position.z = 0.15


//            let orbitAction = SCNAction.rotate(by: .pi, around: planetNode.position, duration: 1)
//            let repeatForever = SCNAction.repeatForever(orbitAction)
//            earthNode.runAction(repeatForever)
            // TODO: Find out how to execute node animations here
            planeNode.addChildNode(planetNode!)
//            planeNode.addChildNode(earthNode)
            node.addChildNode(planeNode)
        }
        
        return node
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Each plane will only contain a single node
//        print(node.childNodes[0].childNodes[0].name)
        let currNode = node.childNodes[0].childNodes[0]
        let refNode = node.childNodes[0]
//        if (currNode.name == "moon") {
//            currNode.runAction(SCNAction.move(by: SCNVector3Make(0.1, 0, 0), duration: 30))
//        }
        curr_time += 1
        
        if currNode.name != nil {
            nodePositions[currNode.name!] = currNode.worldPosition
        }
        if refNode.name != nil {
            refPositions[refNode.name!] = refNode.worldPosition
        }
//        let planetDistance = GLKVector3Distance(nodePositions["moon"]!, nodePositions["sun"]!)
        
        if currNode.name != nil && currNode.name! == "moon" {
            if nodePositions["sun"] != nil {
                let planetDistance = GLKVector3Distance(
                    SCNVector3ToGLKVector3(refPositions["moon_plane"]!), SCNVector3ToGLKVector3(refPositions["sun_plane"]!)
                ) - 0.2
                
                let factor = 0.0872665
                nodeAngles["moon"]! += factor
                // TODO: Rely on factor and planetDistance
//                print (log2(planetDistance*10))

                nodePositions["moon"]!.x = nodePositions["sun"]!.x + planetDistance * Float(cos(nodeAngles["moon"]!))
                nodePositions["moon"]!.y = nodePositions["sun"]!.y + planetDistance * Float(sin(nodeAngles["moon"]!))
                currNode.worldPosition = nodePositions["moon"]!
                currNode.worldPosition.z = nodePositions["sun"]!.z
                print (currNode.worldPosition)
            }
        }

        if currNode.name != nil && currNode.name == "sun" {
            
        }

        if curr_time % 10 == 0 {
            if (nodePositions["moon"] != nil && nodePositions["sun"] != nil) {
//                print ("Distance:" + String(GLKVector3Distance(SCNVector3ToGLKVector3(nodePositions["moon"]!), SCNVector3ToGLKVector3(nodePositions["sun"]!))))
            }
        }
        if let imageAnchor = anchor as? ARImageAnchor {
            if !imageAnchor.isTracked {
                currNode.isHidden = true
            } else {
                currNode.isHidden = false
            }
        }
    }
}
