//
//  GameViewController.swift
//  Mercenary
//
//  Created by William Egesdal on 11/11/17.
//  Copyright © 2017 William Egesdal. All rights reserved.
//

import UIKit
import SpriteKit
class GameViewController: UIViewController {
    static var fuel = 4
    static var maxFuel = 4
    static var credits = 10000
    static var cargo = 0
    static var capacity = 20
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene =
            GameScene(size:CGSize(width: 2048, height: 1536))
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        skView.isMultipleTouchEnabled = true
    }
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if let skView = view as? SKView, let scene = skView.scene as? GameScene {
                scene.shake()
            }
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
