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
    let playableRect: CGRect
    
    override init(size: CGSize) {
        
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight) // 4
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        var background: SKSpriteNode
            background = SKSpriteNode(imageNamed:"Demeter.jpg")
        
        //Planet Description
        let descriptionTextView = UITextView()
        let description = "Earth is storied to be the humble birthplace of humankind. Although once a politically important world to the Inner Ring millenia ago, radiation from forgotten wars have left its inhabitants with horrifying mutations and, if the myths are to be believed, extraordinary gifts."
        descriptionTextView.frame = CGRect(x: 400, y: 20, width: 250, height: 80)
        descriptionTextView.text = description
        descriptionTextView.backgroundColor = UIColor.black
        descriptionTextView.textColor = UIColor.white
        descriptionTextView.font = UIFont(name: "helvetica", size: 16)
        descriptionTextView.isEditable = false
        self.view?.addSubview(descriptionTextView)
        
        //Background
        background.position =
            CGPoint(x: 600, y: 900)
        background.size.width = 1100
        background.size.height = 900
        self.addChild(background)
        
        //Spaceport Bar
        let spaceportBar = SKSpriteNode(imageNamed:"spaceportbar")
        spaceportBar.position =
            CGPoint(x: 300, y: 300)
        spaceportBar.setScale(1.0)
        self.addChild(spaceportBar)
        
        // Mission Computer
        let missionComputer = SKSpriteNode(imageNamed:"missioncomputer")
        missionComputer.position =
            CGPoint(x: 900, y: 300)
        missionComputer.setScale(1.0)
        self.addChild(missionComputer)
        
        
        //MARK: Sidebar
        
        // Refuel
        let refuel = SKSpriteNode(imageNamed:"refuel")
        refuel.position =
            CGPoint(x: 1650, y: 900)
        refuel.setScale(1.0)
        self.addChild(refuel)
        
        // Commodity Exchange
        let commodityExchange = SKSpriteNode(imageNamed:"commodityexchange")
        commodityExchange.position =
            CGPoint(x: 1650, y: 750)
        commodityExchange.setScale(1.0)
        self.addChild(commodityExchange)
        
        // Outfit
        let outfit = SKSpriteNode(imageNamed:"outfit")
        outfit.position =
            CGPoint(x: 1650, y: 600)
        outfit.setScale(1.0)
        self.addChild(outfit)
        
        // Shipyard
        let shipyard = SKSpriteNode(imageNamed:"shipyard")
        shipyard.position =
            CGPoint(x: 1650, y: 450)
        shipyard.setScale(1.0)
        self.addChild(shipyard)
        
        // Leave
        let leave = SKSpriteNode(imageNamed:"leave")
        leave.position =
            CGPoint(x: 1650, y: 300)
        leave.setScale(1.0)
        self.addChild(leave)
        
        let wait = SKAction.wait(forDuration: 10.0)
        let block = SKAction.run {
            let myScene = GameScene(size: self.size)
            myScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 4.5)
            //Only remove UI Elements in main thread or use Grand Central Dispatch:
            descriptionTextView.removeFromSuperview()
            
            self.view?.presentScene(myScene, transition: reveal)
        }
        self.run(SKAction.sequence([wait, block]))
        
    }
}

