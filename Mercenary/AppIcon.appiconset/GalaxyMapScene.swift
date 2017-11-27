//
//  GalaxyMapScene.swift
//  Mercenary
//
//  Created by William Egesdal on 11/20/17.
//  Copyright © 2017 William Egesdal. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
class GalaxyMapScene:SKScene {
    var map: SKTileMapNode!
    override func didMove(to view: SKView) {
        loadSceneNodes()
        var mapX = 0
        var mapY = 0
        var truncatedPlanetNames: [String] = []
        let planetNames = ["AbeonaP.gif", "AditiP.gif", "AegirP.gif", "AntiP.gif", "BadbP.gif", "BalderP.gif", "BelenusP.gif", "BuriP.gif", "CamulosP.gif", "CandraP.gif", "CipactliP.gif", "DaphneP.gif", "DebwenP.gif", "DemeterP.gif", "EAlomP.gif", "EkChuahP.gif", "FaivarongoP.gif", "FujinP.gif", "GarudaS.gif", "GaunabP.gif", "GerraP.gif", "GukumatzS.gif", "HastseyaltiP.gif", "HeimdallS.gif", "HoursP.gif", "HuangTiS.gif", "IgalilikP.gif", "IndraP.gif", "IuturnaP.gif", "JabruS.gif", "JokinamP.gif", "JunoS.gif", "KartaP.gif", "KujuS.gif", "KybeleP.gif", "LeukotheaP.gif"]
        let shuffled = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: planetNames) as! [String]
        for planetName in shuffled {
            let planet = SKSpriteNode(imageNamed: planetName)
        //Add Planets
            
            planet.texture!.filteringMode = .nearest
            planet.setScale(1.0)
            planet.alpha = 0.80
            let planetPosition = map.centerOfTile(atColumn: mapX, row: mapY)
            planet.position = planetPosition
            planet.zPosition = 100
            var truncateAtDotArr = planetName.components(separatedBy: ".")
            let truncatedWithLetter: String = truncateAtDotArr [0]
            let truncatedWithoutLetter = String(truncatedWithLetter[..<truncatedWithLetter.index(before: truncatedWithLetter.endIndex)])
            truncatedPlanetNames.append(truncatedWithoutLetter)
            planet.name = truncatedWithoutLetter
            addChild(planet)
            mapX += 1
            if mapX > 5 {
                mapY += 1
                mapX = 0
            }
        }
        print(truncatedPlanetNames)
    }

    func loadSceneNodes() {

        guard let map = childNode(withName: "map")
            as? SKTileMapNode else {
                fatalError("Background node not loaded")
        }
        self.map = map
        
    }
}


