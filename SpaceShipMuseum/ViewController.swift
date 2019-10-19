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
                if tappedNode?.name != "sun" {
                    let settingStoryboard: UITableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "setting") as UITableViewController
                    self.present(settingStoryboard, animated: true, completion: nil)
                } else {
                    let triviaStoryboard: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "trivia") as UIViewController
                    self.present(triviaStoryboard, animated: true, completion: nil)
                }
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
            
            // MARK: - TitleNode
            let title = "name: " + imageAnchor.name!
            let titleText = SCNText(string: title, extrusionDepth: 0.1)
            titleText.font = UIFont.systemFont(ofSize: 1)
            titleText.flatness = 0.005
            let titleNode = SCNNode(geometry: titleText)
            let fontScale: Float = 0.01
            titleNode.scale = SCNVector3(fontScale, fontScale, fontScale)
            titleNode.position = SCNVector3Zero
            titleNode.position.z  = 0.02
            
            planetNode!.name = imageAnchor.name!
            planetNode!.position = SCNVector3Zero
            planetNode!.position.z = 0.15
            planeNode.addChildNode(planetNode!)
            planeNode.addChildNode(titleNode)
            let detailText = SCNText(string: "", extrusionDepth: 0.1)
            detailText.font = UIFont.systemFont(ofSize: 1)
            detailText.flatness = 0.005
            let detailNode = SCNNode(geometry: detailText)
            detailNode.scale = SCNVector3(fontScale, fontScale, fontScale)
            detailNode.position = SCNVector3Zero
            detailNode.position.z  = 0.02
            detailNode.position.y = -0.02
            planeNode.addChildNode(detailNode)
            
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
        let detailNode = refNode.childNodes[2] // 2 is the detail node

        curr_time += 1
        
//        let planetDistance = GLKVector3Distance(nodePositions["moon"]!, nodePositions["sun"]!)
        if let imageAnchor = anchor as? ARImageAnchor {
            if !imageAnchor.isTracked {
                refNode.isHidden = true
                // Delete the previous points and reset the position
                nodePositions[currNode.name!] = nil
                refPositions[refNode.name!] = nil
                currNode.position = SCNVector3Zero
                currNode.position.z = 0.15
            } else {
                refNode.isHidden = false
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
                }
                
                if (imageAnchor.name != "sun") {
                    var temp = 0 // TODO: inverse square law
                    if (nodePositions["sun"] != nil) {
                        let planetDistance = GLKVector3Distance(
                            SCNVector3ToGLKVector3(refPositions[imageAnchor.name! + "_plane"]!), SCNVector3ToGLKVector3(refPositions["sun_plane"]!)
                        )
                        temp = Int(30/pow(planetDistance, 2))
                    }
                    var detail = "temperature: " + String(temp) + "\n"
                    for (_, element) in selectedElements {
                        var state = ""
                        let bp = Int(element["boiling"]!)
                        let mp = Int(element["melting"]!)
                        if (temp < mp!) {
                            state = "solid"
                        } else if (temp >= mp! && temp < bp!) {
                            state = "liquid"
                        } else {
                            state = "gas"
                        }
                        detail += element["name"]! + ": " + state + "\n"
                    }
                    let detailText = SCNText(string: detail, extrusionDepth: 0.1)
                    detailText.font = UIFont.systemFont(ofSize: 1)
                    detailText.flatness = 0.005
                    detailNode.geometry = detailText
                }
                

            }
        }
    }
}
