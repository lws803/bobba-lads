import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    var planetProps = ["earth": ["index": 2], "sun": ["index": 1]]
    var curr_time = 0
    var nodePositions: [String : SCNVector3] = [:]
    var nodeAngles : [String: Double] = ["earth": 0]
    var refPositions : [String: SCNVector3] = [:]
    var cameraPosition = SCNVector3()
    var selectedElements : [Int: Dictionary<String, String>] = [:]
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        sceneView.addGestureRecognizer(tap)

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

    func reload() {
        print(selectedElements)
    }
    
    // MARK: - GestureRecogniser
    @objc func handleTap(rec: UITapGestureRecognizer){
        if rec.state == .ended {
            let location: CGPoint = rec.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
        
            if !hits.isEmpty{
                let tappedNode = hits.first?.node
                let settingStoryboard: UITableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "setting") as UITableViewController
                self.present(settingStoryboard, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - ARSCNViewDelegate
        
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0)
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi/2
            planeNode.name = imageAnchor.name! + "_plane"

            let planetScene = SCNScene(named: "art.scnassets/ship_sphere.scn")!
            var planetNode: SCNNode?
            planetNode = planetScene.rootNode.childNodes[planetProps[imageAnchor.name!]!["index"]!]
            planetNode!.name = imageAnchor.name!
            planetNode!.position = SCNVector3Zero
            planetNode!.position.z = 0.15
            planeNode.addChildNode(planetNode!)
            node.addChildNode(planeNode)
        }
        
        return node
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do something with the new transform
        cameraPosition = SCNVector3(
            frame.camera.transform.columns.3.x,
            frame.camera.transform.columns.3.y,
            frame.camera.transform.columns.3.z
        )
    }
    
    func setNewPosition (planetName: String, constant: Float) {
        if refPositions[planetName + "_plane"] != nil && refPositions["sun_plane"] != nil {
            let planetDistance = GLKVector3Distance(
                SCNVector3ToGLKVector3(refPositions[planetName + "_plane"]!), SCNVector3ToGLKVector3(refPositions["sun_plane"]!)
            )
            let rotationalRadians = sqrt(constant/planetDistance)
            nodeAngles[planetName]! += Double(rotationalRadians)
            nodePositions[planetName]!.x = nodePositions["sun"]!.x + planetDistance * Float(cos(nodeAngles[planetName]!))
            nodePositions[planetName]!.z = nodePositions["sun"]!.z + planetDistance * Float(sin(nodeAngles[planetName]!))
        }
    }


    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Each plane will only contain a single node
        let currNode = node.childNodes[0].childNodes[0]
        let refNode = node.childNodes[0]

        curr_time += 1
        
//        let planetDistance = GLKVector3Distance(nodePositions["moon"]!, nodePositions["sun"]!)
        if let imageAnchor = anchor as? ARImageAnchor {
            if !imageAnchor.isTracked {
                currNode.isHidden = true
                // Delete the previous points and reset the position
                nodePositions[currNode.name!] = nil
                refPositions[refNode.name!] = nil
                currNode.position = SCNVector3Zero
                currNode.position.z = 0.15
            } else {
                currNode.isHidden = false
                if currNode.name != nil {
                    nodePositions[currNode.name!] = currNode.worldPosition
                }
                if refNode.name != nil {
                    refPositions[refNode.name!] = refNode.worldPosition
                }
                if nodePositions["sun"] != nil {
                    if currNode.name != nil && currNode.name! == "earth" {
                        setNewPosition(planetName: "earth", constant: 0.00172665)
                        currNode.worldPosition = nodePositions["earth"]!
                    }
                    
                    if currNode.name != nil && currNode.name! == "saturn" {
                        // TODO: Hardcode it here
                    }
                }

            }
        }
    }
}
