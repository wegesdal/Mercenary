//
//  GameScene.swift
//  Mercenary
//
//  Created by William Egesdal on 11/11/17.
//  Copyright © 2017 William Egesdal. All rights reserved.
//

import SpriteKit
class GameScene: SKScene {
    
    let ship = SKSpriteNode(imageNamed: "model_N.png")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let shipMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let shipRotateRadiansPerSec: CGFloat = 4.0 * π
    var textures:[SKTexture] = []
    let cameraNode = SKCameraNode()
    
    
    override init(size: CGSize) {
        textures.append(SKTexture(imageNamed: "model_N.png"));
        textures.append(SKTexture(imageNamed: "model_E.png"));
        textures.append(SKTexture(imageNamed: "model_S.png"));
        textures.append(SKTexture(imageNamed: "model_W.png"))
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        let background = SKSpriteNode(imageNamed: "space.png")
        addChild(background)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition -= 1

        ship.position = (CGPoint(x:400, y:400))
        addChild(ship)
        
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0 }
        lastUpdateTime = currentTime
        move(sprite: ship, velocity: velocity)
        rotate(sprite: ship, direction: velocity, rotateRadiansPerSec: shipRotateRadiansPerSec)
        let animationIndex = Int(abs(floor((ship.zRotation.truncatingRemainder(dividingBy: 2*π))/(π/2))).truncatingRemainder(dividingBy: 4))
        ship.texture = textures[animationIndex]
        print(Int(abs(floor((ship.zRotation.truncatingRemainder(dividingBy: 2*π))/(π/2))).truncatingRemainder(dividingBy: 4)))
        cameraNode.position = ship.position

    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
    
    func moveShipToward(location: CGPoint) {
        let offset = CGPoint(x: location.x - ship.position.x, y: location.y - ship.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))

        velocity = CGPoint(x: direction.x * shipMovePointsPerSec, y: direction.y * shipMovePointsPerSec)
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        moveShipToward(location: touchLocation)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
}

