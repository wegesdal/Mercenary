//
//  GameScene.swift
//  Mercenary
//
//  Created by William Egesdal on 11/11/17.
//  Copyright © 2017 William Egesdal. All rights reserved.
//

import SpriteKit
class GameScene: SKScene {
    let planet = SKSpriteNode(imageNamed: "planet.png")
    
    let ship = SKSpriteNode(imageNamed: "model_N.png")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let shipMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let shipRotateRadiansPerSec: CGFloat = 4.0 * π
    var textures:[SKTexture] = []
    let playableRect: CGRect
    
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
    
    
    override init(size: CGSize) {

        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight) // 4
        
        textures.append(SKTexture(imageNamed: "model_S.png"));
        textures.append(SKTexture(imageNamed: "model_E.png"));
        textures.append(SKTexture(imageNamed: "model_N.png"));
        textures.append(SKTexture(imageNamed: "model_W.png"));
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        planet.position = (CGPoint(x:0, y:0))
        planet.zPosition -= 1
        addChild(planet)
        
        physicsWorld.gravity = CGVector(dx:0, dy: 0);
        let gravField = SKFieldNode.radialGravityField(); // Create grav field
        gravField.position = planet.position
        gravField.falloff = 0.1
        gravField.strength = 3
        addChild(gravField); // Add to world
        
        ship.physicsBody = SKPhysicsBody(circleOfRadius: max(ship.size.width / 2, ship.size.height / 2))
        ship.physicsBody?.mass = 5
        backgroundColor = SKColor.black
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position =
                CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            background.zPosition = -1
            addChild(background)
        }
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position =
                CGPoint(x: 0, y: CGFloat(i)*background.size.height)
            background.name = "background"
            background.zPosition = -1
            addChild(background)
        }
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position =
                CGPoint(x: CGFloat(i)*background.size.width, y: CGFloat(i)*background.size.height)
            background.name = "background"
            background.zPosition = -1
            addChild(background)
        }
        
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
        rotate(sprite: ship, direction: velocity, rotateRadiansPerSec: shipRotateRadiansPerSec)
        
        var animationIndex = Int(2.25 + 2*ship.zRotation/π)
        if animationIndex == 4 {
            animationIndex = 0
        }
        ship.texture = textures[animationIndex]
        moveCamera()

    }
    
    func moveShipToward(location: CGPoint) {
        let offset = CGPoint(x: location.x - ship.position.x, y: location.y - ship.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * shipMovePointsPerSec, y: direction.y * shipMovePointsPerSec)
        
        // grab the spaceship rotation and add M_PI_2
        let spaceShipRotation : CGFloat = ship.zRotation
        let calcRotation : Float = Float(spaceShipRotation) + Float(Double.pi);
        
        // cosf and sinf use a Float and return a Float
        // however CGVector need CGFloat
        let intensity : CGFloat = 10000.0 // put your value
        let xv = intensity * CGFloat(cosf(calcRotation))
        let yv = intensity * CGFloat(sinf(calcRotation))
        let vector = CGVector(dx: -xv, dy: -yv)
        
        // apply force to spaceship
        ship.physicsBody?.applyForce(vector)
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
    
    func backgroundNode() -> SKSpriteNode {

        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        
        let background1 = SKSpriteNode(imageNamed: "space")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: "space")
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        let background3 = SKSpriteNode(imageNamed: "space")
        background3.anchorPoint = CGPoint.zero
        background3.position = CGPoint(x: 0, y: background1.size.height)
        backgroundNode.addChild(background3)
        
        let background4 = SKSpriteNode(imageNamed: "space")
        background4.anchorPoint = CGPoint.zero
        background4.position = CGPoint(x: background1.size.width, y: background1.size.height)
        backgroundNode.addChild(background4)
        
        // 4
        backgroundNode.size = CGSize(
            width: background1.size.width*2,
            height: background1.size.height*2)
        return backgroundNode
}
    
    func moveCamera() {
        cameraNode.position = ship.position
        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < self.cameraRect.origin.x {
                background.position = CGPoint(x: background.position.x + background.size.width*2, y: background.position.y)
            }
            if background.position.x - background.size.width > self.cameraRect.origin.x {
                background.position = CGPoint(x: background.position.x - background.size.width*2, y: background.position.y)
            }
            if background.position.y + background.size.height < self.cameraRect.origin.y {
                background.position = CGPoint(x: background.position.x, y: background.position.y + background.size.height*2)
            }
            if background.position.y - background.size.height > self.cameraRect.origin.y {
                background.position = CGPoint(x: background.position.x, y: background.position.y - background.size.height*2)
            }

        }
    }
}

