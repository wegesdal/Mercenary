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
    let planet = SKSpriteNode(imageNamed:"planet")
    let ship = SKSpriteNode(imageNamed:"model_N.png")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let shipMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let shipRotateRadiansPerSec: CGFloat = 4.0*π
    var shipTextures:[SKTexture] = []
    let playableRect: CGRect
    let armorLabel = SKLabelNode(fontNamed: "silom")
    var armor = 1
    let shieldsLabel = SKLabelNode(fontNamed: "silom")
    var shields = 3
    var alive = true
    
    // Seconds elapsed since last action
    var timeSinceLastAction = TimeInterval(0)
    
    // Seconds before performing next action. Choose a default value
    var timeUntilNextAction = TimeInterval(2)
    
    let fuelLabel = SKLabelNode(fontNamed: "silom")
    let creditsLabel = SKLabelNode(fontNamed: "silom")
    
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
        planet.setScale(1.0)
        planet.position = (CGPoint(x:0, y:0))
        planet.zPosition = -1
        addChild(planet)
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx:0, dy: 0);
        let gravField = SKFieldNode.radialGravityField(); // Create grav field
        gravField.position = planet.position
        gravField.falloff = 0.7
        gravField.strength = 3
        addChild(gravField);
        
        //Background
        backgroundColor = SKColor.black
        
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
        
        fuelLabel.text = "Fuel: \(GameViewController.fuel)"
        fuelLabel.fontColor = SKColor.white
        fuelLabel.fontSize = 36
        fuelLabel.zPosition = 150
        fuelLabel.horizontalAlignmentMode = .left
        fuelLabel.verticalAlignmentMode = .bottom
        fuelLabel.position = CGPoint(
            x: -playableRect.size.width/2 + 40,
            y: playableRect.size.height/2 - CGFloat(40))
        cameraNode.addChild(fuelLabel)
        
        armorLabel.text = "Armor: \(armor)"
        armorLabel.fontColor = SKColor.white
        armorLabel.fontSize = 36
        armorLabel.zPosition = 150
        armorLabel.horizontalAlignmentMode = .left
        armorLabel.verticalAlignmentMode = .bottom
        armorLabel.position = CGPoint(
            x: -playableRect.size.width/2 + 220,
            y: playableRect.size.height/2 - CGFloat(40))
        cameraNode.addChild(armorLabel)
        
        shieldsLabel.text = "Shields: \(shields)"
        shieldsLabel.fontColor = SKColor.white
        shieldsLabel.fontSize = 36
        shieldsLabel.zPosition = 150
        shieldsLabel.horizontalAlignmentMode = .left
        shieldsLabel.verticalAlignmentMode = .bottom
        shieldsLabel.position = CGPoint(
            x: -playableRect.size.width/2 + 420,
            y: playableRect.size.height/2 - CGFloat(40))
        cameraNode.addChild(shieldsLabel)
        
        // Add Starfield with 3 emitterNodes for a parallax effect
        // - Stars in top layer: light, fast, big
        // - ...
        // - Stars in back layer: dark, slow, small
        var emitterNode = starfieldEmitter(color: SKColor.lightGray, starSpeedY: 9, starsPerSecond: 1, starScaleFactor: 0.2)
        emitterNode.name = "topNode"
        emitterNode.zPosition = -10
        cameraNode.addChild(emitterNode)
        
        emitterNode = starfieldEmitter(color: SKColor.gray, starSpeedY: 6, starsPerSecond: 2, starScaleFactor: 0.1)
        emitterNode.name = "midNode"
        emitterNode.zPosition = -11
        cameraNode.addChild(emitterNode)
        
        emitterNode = starfieldEmitter(color: SKColor.darkGray, starSpeedY: 3, starsPerSecond: 4, starScaleFactor: 0.05)
        emitterNode.name = "botNode"
        emitterNode.zPosition = -12
        cameraNode.addChild(emitterNode)

    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0 }
        lastUpdateTime = currentTime

        timeSinceLastAction += dt
        
        if timeSinceLastAction >= timeUntilNextAction {
            
        // perform your action
            if shields < 1 && alive == true {
            //sirens
            run(SKAction.playSoundFileNamed("sfx_movement_portal4.wav", waitForCompletion: false))
            let colorOn = SKAction.colorize(with: SKColor.red, colorBlendFactor: 1, duration: 0.1)
            let colorOff = SKAction.colorize(with: SKColor.white, colorBlendFactor: 1, duration: 0.7)
            let actions = [colorOn, colorOff]
            ship.run(SKAction.sequence(actions))
            }
            
        // reset
        timeSinceLastAction = TimeInterval(0)
        //Seconds until next action
        timeUntilNextAction = 1
        }
        
        rotate(sprite: ship, direction: velocity, rotateRadiansPerSec: shipRotateRadiansPerSec)
        
        //move parallax
        cameraNode.childNode(withName: "topNode")?.position.x = -ship.position.x/12
        cameraNode.childNode(withName: "topNode")?.position.y = -ship.position.y/12
        cameraNode.childNode(withName: "midNode")?.position.x = -ship.position.x/24
        cameraNode.childNode(withName: "midNode")?.position.y = -ship.position.y/24
        cameraNode.childNode(withName: "botNode")?.position.x = -ship.position.x/36
        cameraNode.childNode(withName: "botNode")?.position.y = -ship.position.y/36
        
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
        let vector = CGVector(dx: -xv/2.5, dy: -yv/2.5)
        
        // apply force to spaceship
        ship.physicsBody?.applyForce(vector)
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        moveShipToward(location: touchLocation)
        if planet.contains(touchLocation) && planet.contains(ship.position) {
            if let unwrappedShip = ship.physicsBody {
                if abs(unwrappedShip.velocity.dx) > 100 {
                    run(SKAction.playSoundFileNamed("sfx_sounds_error13.wav",
                                                    waitForCompletion: false))
                } else {
                    run(SKAction.playSoundFileNamed("sfx_sounds_falling8.wav",
                                                    waitForCompletion: false))
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
    
    func moveCamera() {
        cameraNode.position = ship.position
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
                alive = false

            } else {
                triggerShield(contactPoint: contact.contactPoint, contactNormal: contact.contactNormal)
                run(SKAction.playSoundFileNamed("sfx_exp_odd6.wav", waitForCompletion: false))
                shields -= 1
                shieldsLabel.text = "Shields: \(shields)"
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
    
    func starfieldEmitter(color: SKColor, starSpeedY: CGFloat, starsPerSecond: CGFloat, starScaleFactor: CGFloat) -> SKEmitterNode {
        
        // Determine the time a star is visible on screen
        let lifetime =  frame.size.height * UIScreen.main.scale / starSpeedY
        
        // Create the emitter node
        let emitterNode = SKEmitterNode()
        emitterNode.particleTexture = SKTexture(imageNamed: "Star")
        emitterNode.particleBirthRate = starsPerSecond
        emitterNode.particleColor = SKColor.lightGray
        emitterNode.particleSpeed = starSpeedY * -1
        emitterNode.particleScale = starScaleFactor
        emitterNode.particleColorBlendFactor = 1
        emitterNode.particleLifetime = lifetime
        
        // Position in the middle at top of the screen
        emitterNode.position = CGPoint(x: frame.size.width/2, y: frame.size.height)
        emitterNode.particlePositionRange = CGVector(dx: frame.size.width*3, dy: frame.size.height*3)
        
        // Fast forward the effect to start with a filled screen
        emitterNode.advanceSimulationTime(TimeInterval(lifetime))
        
        return emitterNode
    }
}



