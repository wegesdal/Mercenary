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
    let spaceportBar = SKSpriteNode(imageNamed:"spaceportbar")
    let missionComputer = SKSpriteNode(imageNamed:"missioncomputer")
    let refuel = SKSpriteNode(imageNamed:"refuel")
    let commodityExchange = SKSpriteNode(imageNamed:"commodityexchange")
    let outfit = SKSpriteNode(imageNamed:"outfit")
    let shipyard = SKSpriteNode(imageNamed:"shipyard")
    let leave = SKSpriteNode(imageNamed:"leave")
    var fuel = GameViewController.fuel
    var maxFuel = GameViewController.maxFuel
    let descriptionTextView = UITextView()
    
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

        let description = "Earth is storied to be the humble birthplace of humankind. Although once a politically important world to the Inner Ring millenia ago, radiation from forgotten wars have left its inhabitants with horrifying mutations and, if the myths are to be believed, extraordinary gifts."
        
        descriptionTextView.frame = CGRect(x: 400, y: 10, width: 250, height: 100)
        descriptionTextView.text = description
        descriptionTextView.backgroundColor = UIColor.black
        descriptionTextView.textColor = UIColor.white
        descriptionTextView.font = UIFont(name: "helvetica", size: 16)
        descriptionTextView.isEditable = false
        self.view?.addSubview(descriptionTextView)
        
        //Background
        background.position =
            CGPoint(x: 600, y: 850)
        background.size.width = 900
        background.size.height = 600
        self.addChild(background)
        
        //Spaceport Bar

        spaceportBar.position =
            CGPoint(x: 300, y: 300)
        spaceportBar.setScale(1.0)
        self.addChild(spaceportBar)
        
        // Mission Computer

        missionComputer.position =
            CGPoint(x: 900, y: 300)
        missionComputer.setScale(1.0)
        self.addChild(missionComputer)
        
        
        //MARK: Sidebar
        
        // Refuel

        refuel.position =
            CGPoint(x: 1600, y: 900)
        refuel.setScale(1.0)
        self.addChild(refuel)
        
        // Commodity Exchange

        commodityExchange.position =
            CGPoint(x: 1600, y: 750)
        commodityExchange.setScale(1.0)
        self.addChild(commodityExchange)
        
        // Outfit

        outfit.position =
            CGPoint(x: 1600, y: 600)
        outfit.setScale(1.0)
        self.addChild(outfit)
        
        // Shipyard

        shipyard.position =
            CGPoint(x: 1600, y: 450)
        shipyard.setScale(1.0)
        self.addChild(shipyard)
        
        // Leave

        leave.position =
            CGPoint(x: 1600, y: 300)
        leave.setScale(1.0)
        self.addChild(leave)
    
    }
    func sceneTouched(touchLocation:CGPoint) {
        
        //Spaceport Bar
        if spaceportBar.contains(touchLocation) {
            print("spaceportBar")
            run(SKAction.playSoundFileNamed("sfx_coin_cluster3.wav", waitForCompletion: false))
            
        }
        
        //Mission Computer
        if missionComputer.contains(touchLocation) {
            print("missionComputer")
            run(SKAction.playSoundFileNamed("sfx_coin_cluster3.wav", waitForCompletion: false))
            
        }
        
        //Refuel
        if refuel.contains(touchLocation) {
            if GameViewController.fuel < GameViewController.maxFuel {
                GameViewController.fuel = GameViewController.maxFuel
                GameViewController.credits -= 500*(GameViewController.maxFuel-GameViewController.fuel)
                run(SKAction.playSoundFileNamed("sfx_sound_poweron.wav", waitForCompletion: false))
            } else {
                run(SKAction.playSoundFileNamed("sfx_sounds_error13.wav", waitForCompletion: false))
            }
        }
        
        //Commodity Exchange
        if commodityExchange.contains(touchLocation) {
            print("commodityExchange")
            run(SKAction.playSoundFileNamed("sfx_coin_cluster3.wav", waitForCompletion: false))
            
        }
        
        //Outfit
        if outfit.contains(touchLocation) {
            print("outfit")
            run(SKAction.playSoundFileNamed("sfx_coin_cluster3.wav", waitForCompletion: false))
            
        }
        
        //Shipyard
        if shipyard.contains(touchLocation) {
            print("shipyard")
            run(SKAction.playSoundFileNamed("sfx_coin_cluster3.wav", waitForCompletion: false))
            
        }
        
        //Leave
        if leave.contains(touchLocation) {
            run(SKAction.playSoundFileNamed("sfx_sound_poweron.wav", waitForCompletion: false))
            let wait = SKAction.wait(forDuration: 0.2)
            let block = SKAction.run {
            let myScene = GameScene(size: self.size)
            myScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            //Only remove UI Elements in main thread or use Grand Central Dispatch:
            self.descriptionTextView.removeFromSuperview()
            self.view?.presentScene(myScene, transition: reveal)
            }
        self.run(SKAction.sequence([wait, block]))
            }
        }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
}

