//
//  GameOverScene.swift
//  Mercenary
//
//  Created by William Egesdal on 11/12/17.
//  Copyright © 2017 William Egesdal. All rights reserved.
//

import Foundation
import SpriteKit
class GameOverScene: SKScene {
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        var background: SKSpriteNode
        background = SKSpriteNode(imageNamed: "YouDie.png")
        run(SKAction.playSoundFileNamed("sfx_deathscream_human3.wav",
                                                waitForCompletion: false))
        background.position =
                CGPoint(x: size.width/2, y: size.height/2)
        self.addChild(background)
        let wait = SKAction.wait(forDuration: 3.0)
        let block = SKAction.run {
        let myScene = GameScene(size: self.size)
        myScene.scaleMode = self.scaleMode
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        self.view?.presentScene(myScene, transition: reveal)
        }
    self.run(SKAction.sequence([wait, block]))
    }
}
