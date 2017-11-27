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
        let planetNames = ["AbeonaP.gif", "AditiP.gif", "AegirP.gif", "AntiP.gif", "BadbP.gif", "BalderP.gif", "BuriP.gif", "CamulosP.gif", "CandraP.gif", "CipactliP.gif", "DaphneP.gif", "DebwenP.gif", "DemeterP.gif", "EAlomP.gif", "EkChuahP.gif", "FaivarongoP.gif", "FujinP.gif", "GarudaS.gif", "GaunabP.gif", "GerraP.gif", "GukumatzS.gif", "HastseyaltiP.gif", "HeimdallS.gif", "HoursP.gif", "HuangTiS.gif", "IgalilikP.gif", "IndraP.gif", "IuturnaP.gif", "JabruS.gif", "JokinamP.gif", "JunoS.gif", "KartaP.gif", "KujuS.gif", "KybeleP.gif", "LeukotheaP.gif", "LiluriP.gif", "LomoP.gif", "MamlamboP.gif", "NingiramaP.gif", "OsandeP.gif", "PoenimusP.gif", "QeskinaquS.gif", "RanP.gif", "SganaP.gif", "SisyphosP.gif", "SogblenP.gif", "TinP.gif", "TuleS.gif", "UsasP.gif", "UsinsS.gif", "WajetP.gif", "WepwawetP.gif", "WusquusS.gif", "XolotlNanahuatlP.gif", "YamadutiP.gif", "YinamtilanP.gif", "YumCimilP.gif", "ZababaP.gif", "ZipaknaP.gif", "ZurvanP.gif"]
        let shuffled = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: planetNames) as! [String]
        for planetName in shuffled {
            let planet = SKSpriteNode(imageNamed: planetName)
            
        //Add Planets
            //Best filtering mode for pixel art is .nearest
            planet.texture!.filteringMode = .nearest
            planet.setScale(1.0)
            planet.alpha = 0.80
            let planetPosition = map.centerOfTile(atColumn: mapX, row: mapY)
            planet.position = planetPosition
            planet.zPosition = 100
            // truncate the gif filename to use for planet name and planetside portrait jpg
            var truncateAtDotArr = planetName.components(separatedBy: ".")
            let truncatedWithLetter: String = truncateAtDotArr [0]
            let truncatedWithoutLetter = String(truncatedWithLetter[..<truncatedWithLetter.index(before: truncatedWithLetter.endIndex)])
            truncatedPlanetNames.append(truncatedWithoutLetter)
            planet.name = truncatedWithoutLetter
            addChild(planet)
            mapX += 1
            if mapX > 9 {
                mapY += 1
                mapX = 0
            }
        }
        //store array of truncated planet names
        print(truncatedPlanetNames)
    }

    func loadSceneNodes() {

        guard let map = childNode(withName: "map")
            as? SKTileMapNode else {
                fatalError("Background node not loaded")
        }
        self.map = map
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        print("touched")
        childNode(withName: "thumb")?.removeFromParent()
        for node in children {
            if node.name != "map" {
                if node.contains(touchLocation) {
                    run(SKAction.playSoundFileNamed("sfx_menu_select4.wav", waitForCompletion: false))
                    if let portraitFilename = node.name {
                        
                        let portrait = portraitFilename + ".jpg"
                        print(portrait)
                        let thumb = SKSpriteNode(imageNamed: portrait)
                        thumb.zPosition = -100
                        thumb.name = "thumb"
                        addChild(thumb)
                    } else {
                        print("There are no portraits with that name.")
                    }

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
}



