//
//  ViewController.swift
//  CuriosityPacMan
//
//  Created by Lucas Cardoso on 27/07/19.
//  Copyright © 2019 Lucas Cardoso. All rights reserved.
//

import UIKit
import SpriteKit
import MultipeerConnectivity

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    
    @IBOutlet weak var mySKView: SKView!
    lazy var scene = GameScene(fileNamed: "GameScene")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CONEXAO COM IPHONE
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        mcSession.delegate = self
        
        self.startHosting()
        
        startGameScene()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)

    }
    
    func startGameScene() {
        // MOSTRAR TELA INICIAL
        self.scene = GameScene(fileNamed: "GameScene")!
        self.scene.scaleMode = .aspectFill
        self.mySKView.presentScene(self.scene)
        
        scene.endGameFunction = presentEndGameAlert
        
        self.mySKView.ignoresSiblingOrder = true
        self.mySKView.showsFPS = true
        self.mySKView.showsNodeCount = true
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
            self.scene.setP1Direction(direction: .right)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            print("Swipe Left")
            self.scene.setP1Direction(direction: .left)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            print("Swipe Up")
            self.scene.setP1Direction(direction: .up)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            print("Swipe Down")
            self.scene.setP1Direction(direction: .down)
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        @unknown default:
            print("Unknown connection")
            fatalError()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let command = String(data: data, encoding: .utf8){
            DispatchQueue.main.async { [unowned self] in
                if let side = Direction.fromString(side: command){
                    self.scene.setP2Direction(direction: side)
                }
                print(command)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        
    }
    
    func startHosting() {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func presentEndGameAlert(winner: String) {
        let alert = UIAlertController(title: "Game Over", message: "O vencedor é " + winner, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { (UIAlertAction) in
            self.startGameScene()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

