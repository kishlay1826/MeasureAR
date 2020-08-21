//
//  ViewController.swift
//  MeasureAR
//
//  Created by Kishlay Chhajer on 2020-08-21.
//  Copyright © 2020 Kishlay Chhajer. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dots = [SCNNode]()
    var distanceTextNode = SCNNode()
    var line = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dots.count >= 2 {
            for dot in dots {
                dot.removeFromParentNode()
            }
            dots = []
        }
        if let touch = touches.first {
            let location = touch.location(in: sceneView)
            let results = sceneView.hitTest(location, types: .featurePoint)
            if let result = results.first {
                addDot(at: result)
            }
        }
    }
    
    func addDot(at location: ARHitTestResult) {
        let dot = SCNSphere(radius: 0.007)
        let material = SCNMaterial()
        material.diffuse.contents = [material]
        let node = SCNNode(geometry: dot)
        
        node.position = SCNVector3(x: location.worldTransform.columns.3.x, y: location.worldTransform.columns.3.y, z: location.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(node)
        dots.append(node)
        if dots.count >= 2 {
            calculate()
        }
    }
    
    func calculate() {
        let firstPoint = dots[0]
        let secondPoint = dots[1]
        let distance = sqrt(pow((secondPoint.position.x - firstPoint.position.x), 2) + pow((secondPoint.position.y - firstPoint.position.y), 2) + pow((secondPoint.position.z - firstPoint.position.z), 2))
        printTextOnScreen(distance: String(format: "%.2f", abs(distance * 100)), position: secondPoint.position)
        
        addLines(firstPoint, secondPoint)
    }
    
    func addLines(_ firstPoint: SCNNode, _ secondPoint: SCNNode) {
        line.removeFromParentNode()
        let vertices: [SCNVector3] = [
                   SCNVector3(firstPoint.position.x, firstPoint.position.y, firstPoint.position.z),
                   SCNVector3(secondPoint.position.x, secondPoint.position.y, secondPoint.position.z)
               ]

               let linesGeometry = SCNGeometry(
                   sources: [
                       SCNGeometrySource(vertices: vertices)
                   ],
                   elements: [
                       SCNGeometryElement(
                           indices: [Int32]([0, 1]),
                           primitiveType: .line
                       )
                   ]
               )

               line = SCNNode(geometry: linesGeometry)
               sceneView.scene.rootNode.addChildNode(line)
    }
    
    func printTextOnScreen(distance: String, position: SCNVector3) {
        distanceTextNode.removeFromParentNode()
        let distanceText = SCNText(string: "\(distance)cm", extrusionDepth: 1.0)
        distanceText.firstMaterial?.diffuse.contents = UIColor.blue
        distanceTextNode = SCNNode(geometry: distanceText)
        distanceTextNode.position = SCNVector3(position.x, position.y, position.z)
        distanceTextNode.scale = SCNVector3(0.01, 0.01, 0.01)
        sceneView.scene.rootNode.addChildNode(distanceTextNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}
