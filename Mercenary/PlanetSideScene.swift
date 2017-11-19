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
    let cameraNode = SKCameraNode()
    let cameraMovePointsPerSec: CGFloat = 200.0
    var cameraRect : CGRect {
        let x = cameraNode.position.x - size.width/2
            + (size.width - playableRect.width)/2
        let y = cameraNode.position.y - size.height/2
            + (size.height - playableRect.height)/2
        return CGRect(
            x: x,
            y: y,
            width: playableRect.width,
            height: playableRect.height)
    }

    let descriptionTextView = UITextView()
    
    override init(size: CGSize) {
        
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight)
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        var background: SKSpriteNode
            background = SKSpriteNode(imageNamed:"Demeter.jpg")
        
        
        //Add Camera
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        
        //Planet Description

        let description = "Named for Demeter, goddess of death and rebirth. Once breadbasket of the Core, it remains under strict martial law following the emergence of a mysterious plague."
        
        descriptionTextView.frame = CGRect(x: 5, y: 200, width: 400, height: 285)
        descriptionTextView.text = description
        descriptionTextView.backgroundColor = UIColor.black
        descriptionTextView.textColor = UIColor.white
        descriptionTextView.font = UIFont(name: "helvetica", size: 16)
        descriptionTextView.isEditable = false
        self.view?.addSubview(descriptionTextView)
        
        //Background
        background.texture!.filteringMode = .nearest
        background.setScale(2.0)
        background.position =
            CGPoint(x: 625, y: 1000)
        self.addChild(background)
        
        //Add UIElements

        let creditsLabel = SKLabelNode(fontNamed: "silom")
        creditsLabel.text = "Credits: \(GameViewController.credits)"
        creditsLabel.fontColor = SKColor.white
        creditsLabel.fontSize = 36
        creditsLabel.zPosition = 150
        creditsLabel.horizontalAlignmentMode = .left
        creditsLabel.verticalAlignmentMode = .bottom
        creditsLabel.position = CGPoint(
            x: playableRect.size.width/6,
            y: -playableRect.size.height/2 + CGFloat(20))
        cameraNode.addChild(creditsLabel)
        
        let fuelLabel = SKLabelNode(fontNamed: "silom")
        fuelLabel.text = "Fuel: \(GameViewController.fuel)"
        fuelLabel.fontColor = SKColor.white
        fuelLabel.fontSize = 36
        fuelLabel.zPosition = 150
        fuelLabel.horizontalAlignmentMode = .left
        fuelLabel.verticalAlignmentMode = .bottom
        fuelLabel.position = CGPoint(
            x: playableRect.size.width/6,
            y: playableRect.size.height/2 - CGFloat(40))
        cameraNode.addChild(fuelLabel)
        
        
        //MARK: Sidebar
        
        // Refuel
        
        refuel.position =
            CGPoint(x: 1650, y: 1225)
        refuel.setScale(1.0)
        self.addChild(refuel)
        
        //Spaceport Bar

        spaceportBar.position =
            CGPoint(x: 1650, y: 1075)
        spaceportBar.setScale(1.0)
        self.addChild(spaceportBar)
        
        // Mission Computer

        missionComputer.position =
            CGPoint(x: 1650, y: 925)
        missionComputer.setScale(1.0)
        self.addChild(missionComputer)
        
    
        // Commodity Exchange

        commodityExchange.position =
            CGPoint(x: 1650, y: 775)
        commodityExchange.setScale(1.0)
        self.addChild(commodityExchange)
        
        // Outfit

        outfit.position =
            CGPoint(x: 1650, y: 625)
        outfit.setScale(1.0)
        self.addChild(outfit)
        
        // Shipyard

        shipyard.position =
            CGPoint(x: 1650, y: 475)
        shipyard.setScale(1.0)
        self.addChild(shipyard)
        
        // Leave

        leave.position =
            CGPoint(x: 1650, y: 325)
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


