//
//  GalaxyMapScene.swift
//  Mercenary
//
//  Created by William Egesdal on 11/20/17.
//  Copyright © 2017 William Egesdal. All rights reserved.
//

import Foundation
import SpriteKit
class GalaxyMapScene:SKScene {
    var map: SKTileMapNode!
    let planet = SKSpriteNode(imageNamed:"DemeterP.gif")
    override func didMove(to view: SKView) {
        loadSceneNodes()
        //Add Planet
        planet.name = "planet"
        planet.texture!.filteringMode = .nearest
        planet.setScale(5.0)
        planet.position = (CGPoint(x:0, y:0))
        planet.zPosition = 100
        addChild(planet)
    }

    func loadSceneNodes() {

        guard let map = childNode(withName: "map")
            as? SKTileMapNode else {
                fatalError("Background node not loaded")
        }
        self.map = map
        
    }
}


