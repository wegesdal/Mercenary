//
//  PlanetSide.swift
//  Mercenary
//
//  Created by William Egesdal on 11/13/17.
//  Copyright © 2017 William Egesdal. All rights reserved.
//

import Foundation
import SpriteKit
class PlanetSideScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        var background: SKSpriteNode
            background = SKSpriteNode(imageNamed:"Demeter.jpg")
            run(SKAction.playSoundFileNamed("sfx_sound_mechanicalnoise6.wav",
                                            waitForCompletion: false))
        background.position =
            CGPoint(x: size.width/4 , y: size.height/1.33)
        background.setScale(3.0)
        self.addChild(background)
        let wait = SKAction.wait(forDuration: 10.0)
        let block = SKAction.run {
            let myScene = GameScene(size: self.size)
            myScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 4.5)
            self.view?.presentScene(myScene, transition: reveal)
        }
        self.run(SKAction.sequence([wait, block]))
    }
}

