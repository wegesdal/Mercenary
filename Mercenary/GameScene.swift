//
//  GameScene.swift
//  Mercenary
//
//  Created by William Egesdal on 11/11/17.
//  Copyright © 2017 William Egesdal. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let atlas = SKTextureAtlas(named: "atlas")
    let planet = SKSpriteNode(imageNamed:"DemeterP.gif")
    let ship = SKSpriteNode(imageNamed:"model_N.png")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let shipMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let shipRotateRadiansPerSec: CGFloat = 4.0*π
    var shipTextures:[SKTexture] = []
    let playableRect: CGRect
    let livesLabel = SKLabelNode(fontNamed: "zapfino")
    var shields = 3
    
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
        
        ship.name = "ship"
        shipTextures.append(atlas.textureNamed("model_S.png"));
        shipTextures.append(atlas.textureNamed("model_E.png"));
        shipTextures.append(atlas.textureNamed("model_N.png"));
        shipTextures.append(atlas.textureNamed("model_W.png"))
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        
        //Add Planet
        planet.name = "planet"
        planet.setScale(6.0)
        planet.position = (CGPoint(x:0, y:0))
        planet.zPosition = -1
        addChild(planet)
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx:0, dy: 0);
        let gravField = SKFieldNode.radialGravityField(); // Create grav field
        gravField.position = planet.position
        gravField.falloff = 1
        gravField.strength = 2
        addChild(gravField);
        
        
        //Scrolling Background
        backgroundColor = SKColor.black

        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position =
                CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            background.zPosition = -2
            addChild(background)
        }
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position =
                CGPoint(x: 0, y: CGFloat(i)*background.size.height)
            background.name = "background"
            background.zPosition = -2
            addChild(background)
        }
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position =
                CGPoint(x: CGFloat(i)*background.size.width, y: CGFloat(i)*background.size.height)
            background.name = "background"
            background.zPosition = -2
            addChild(background)
        }
        
        //Add Ship
        ship.physicsBody = SKPhysicsBody(circleOfRadius: max(ship.size.width / 2, ship.size.height / 2))
        ship.physicsBody?.mass = 5
        ship.position = (CGPoint(x:400, y:400))
        addChild(ship)
        
        //Add Camera
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        
        //Add Asteroids
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run() { [weak self] in self?.spawnAsteroid()}, SKAction.wait(forDuration: 3.0)])))
        
        //Add UIElements

        livesLabel.text = "Shields: \(shields)"
        livesLabel.fontColor = SKColor.green
        livesLabel.fontSize = 48
        livesLabel.zPosition = 150
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .bottom
        livesLabel.position = CGPoint(
            x: -playableRect.size.width/2 + CGFloat(20),
            y: -playableRect.size.height/2 + CGFloat(20))
        cameraNode.addChild(livesLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0 }
        lastUpdateTime = currentTime
        rotate(sprite: ship, direction: velocity, rotateRadiansPerSec: shipRotateRadiansPerSec)
        
        var shipAnimationIndex = Int(2.5 + 2*ship.zRotation/π)
        if shipAnimationIndex >= 4 {
            shipAnimationIndex = 0
        }
        if shipAnimationIndex > -1 {
            ship.texture = shipTextures[shipAnimationIndex]
        }
        moveCamera()
    }
    
    func moveShipToward(location: CGPoint) {
        let offset = CGPoint(x: location.x - ship.position.x, y: location.y - ship.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * shipMovePointsPerSec, y: direction.y * shipMovePointsPerSec)
        
        // grab the spaceship rotation and add 2π
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
        if planet.contains(touchLocation) && planet.contains(ship.position) {
            if let speed = ship.physicsBody {
                if speed.velocity.dx > 100 {
                    print("you are moving too fast to land")
                } else {
                    print("land that shit")
                    landShip()
                    
                }
            }
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
        
        let background1 = SKSpriteNode(texture: atlas.textureNamed("space.png"))
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode(texture: atlas.textureNamed("space.png"))
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        let background3 = SKSpriteNode(texture: atlas.textureNamed("space.png"))
        background3.anchorPoint = CGPoint.zero
        background3.position = CGPoint(x: 0, y: background1.size.height)
        backgroundNode.addChild(background3)
        
        let background4 = SKSpriteNode(texture: atlas.textureNamed("space.png"))
        background4.anchorPoint = CGPoint.zero
        background4.position = CGPoint(x: background1.size.width, y: background1.size.height)
        backgroundNode.addChild(background4)
        
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
    
    func spawnAsteroid() {
        let asteroid = SKSpriteNode(texture: atlas.textureNamed("asteroid.png"))
        asteroid.position = CGPoint(
            x: CGFloat.random(min: playableRect.minX,
                              max: playableRect.maxX),
            y: CGFloat.random(min: playableRect.minY,
                              max: playableRect.maxY))
        asteroid.setScale(0)
        asteroid.name = "asteroid"
        addChild(asteroid)
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: max(ship.size.width / 2, ship.size.height / 2))
        asteroid.physicsBody?.mass = 12
        asteroid.physicsBody?.applyAngularImpulse(0.5)
        asteroid.physicsBody!.contactTestBitMask = asteroid.physicsBody!.collisionBitMask
        
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        let wait = SKAction.wait(forDuration: 10.0)

        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, wait, disappear, removeFromParent]
        asteroid.run(SKAction.sequence(actions))
    }
    
    func spawnChips(contactPoint:CGPoint, contactNormal:CGVector) {
        let chip = SKSpriteNode(texture: atlas.textureNamed("chip.png"))
        chip.position = contactPoint
        chip.name = "chip"
        addChild(chip)
        chip.physicsBody = SKPhysicsBody(circleOfRadius: max(chip.size.width / 2, chip.size.height / 2))
        chip.physicsBody?.mass = 3
        chip.physicsBody?.applyImpulse(contactNormal)
        chip.physicsBody?.applyAngularImpulse(0.1)
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        let wait = SKAction.wait(forDuration: 10.0)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, wait, disappear, removeFromParent]
        chip.run(SKAction.sequence(actions))
    }
    
    func spawnScrap(contactPoint:CGPoint, contactNormal:CGVector) {
        let scraps = [SKSpriteNode(texture: atlas.textureNamed("shuttlechassis.model")), SKSpriteNode(texture: atlas.textureNamed("shuttlewindshield.model")), SKSpriteNode(texture: atlas.textureNamed("shuttlecargobay.model"))]
        for scrap in scraps {
            scrap.position = contactPoint
            scrap.name = "scrap"
            addChild(scrap)
            scrap.physicsBody = SKPhysicsBody(circleOfRadius: max(scrap.size.width / 2, scrap.size.height / 2))
            scrap.physicsBody?.mass = 1.6
            scrap.physicsBody?.applyImpulse(contactNormal)
            scrap.physicsBody?.applyAngularImpulse(0.09)
            
            let appear = SKAction.scale(to: 1.0, duration: 0.5)
            let wait = SKAction.wait(forDuration: 10.0)
            let disappear = SKAction.scale(to: 0, duration: 0.5)
            let removeFromParent = SKAction.removeFromParent()
            let death = SKAction.run{self.deathFunction()}
            let actions = [appear, wait, disappear, death, removeFromParent]
            scrap.run(SKAction.sequence(actions))
        }
    }
    
    func deathFunction(){
        let gameOverScene = GameOverScene(size: size, won: false)
        gameOverScene.scaleMode = scaleMode
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameOverScene, transition: reveal)
    }
    
    func landShip(){
        let planetSide = PlanetSideScene(size:size)
        planetSide.scaleMode = scaleMode
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(planetSide, transition: reveal)
    }
    
     func triggerShield(contactPoint:CGPoint, contactNormal:CGVector) {
        ship.physicsBody?.applyImpulse(contactNormal)
        let shieldBlast = shieldSplosion(intensity: 0.2)
        shieldBlast.position = contactPoint
        addChild(shieldBlast)
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "ship" {
            for _ in 0...2 {
                spawnChips(contactPoint: contact.contactPoint, contactNormal: contact.contactNormal)
                contact.bodyB.node?.removeFromParent()
            }
            if shields < 1 {
                spawnScrap(contactPoint: contact.contactPoint, contactNormal: contact.contactNormal)
                run(SKAction.playSoundFileNamed("sfx_exp_odd4.wav", waitForCompletion: false))
                contact.bodyA.node?.removeFromParent()
                let bombBlast = explosion(intensity: 0.6)
                bombBlast.position = contact.contactPoint
                addChild(bombBlast)

            } else {
                triggerShield(contactPoint: contact.contactPoint, contactNormal: contact.contactNormal)
                run(SKAction.playSoundFileNamed("sfx_exp_odd6.wav", waitForCompletion: false))
                shields -= 1
                livesLabel.text = "Shields: \(shields)"
            }
        } else if contact.bodyB.node?.name == "asteroid" {
        }
    }
    
    // MARK: - Particles
    func explosion(intensity: CGFloat) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        let particleTexture = SKTexture(imageNamed: "spark")
        emitter.zPosition = 2
        emitter.particleTexture = particleTexture
        emitter.particleBirthRate = 4000 * intensity
        emitter.numParticlesToEmit = Int(400 * intensity)
        emitter.particleLifetime = 2.0
        emitter.emissionAngle = CGFloat(π/2)
        emitter.emissionAngleRange = CGFloat(2*π)
        emitter.particleSpeed = 600 * intensity
        emitter.particleSpeedRange = 1000 * intensity
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.25
        emitter.particleScale = 1.2
        emitter.particleScaleRange = 2.0
        emitter.particleScaleSpeed = -1.5
        emitter.particleColor = SKColor.orange
        emitter.particleColorBlendFactor = 1
        emitter.particleBlendMode = SKBlendMode.add
        emitter.run(SKAction.removeFromParentAfterDelay(2.0))
        return emitter
    }
    func shieldSplosion(intensity: CGFloat) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        let particleTexture = SKTexture(imageNamed: "shield")
        emitter.zPosition = 2
        emitter.particleTexture = particleTexture
        emitter.particleBirthRate = 4000 * intensity
        emitter.numParticlesToEmit = Int(24 * intensity)
        emitter.particleLifetime = 2.0
        emitter.emissionAngle = CGFloat(π/2)
        emitter.emissionAngleRange = CGFloat(2*π)
        emitter.particleSpeed = 600 * intensity
        emitter.particleSpeedRange = 1000 * intensity
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.25
        emitter.particleScale = 1.2
        emitter.particleScaleRange = 2.0
        emitter.particleScaleSpeed = -1.5
        emitter.particleColor = SKColor.green
        emitter.particleColorBlendFactor = 1
        emitter.particleBlendMode = SKBlendMode.add
        emitter.run(SKAction.removeFromParentAfterDelay(2.0))
        return emitter
    }
}



