//
//  GameScene.swift
//  Project11
//
//  Created by Paul Richardson on 29/04/2021.
//

import SpriteKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {

	
	override func didMove(to view: SKView) {
		let background = SKSpriteNode(imageNamed: "background.jpg")
		background.position = CGPoint(x: 512, y: 384)
		background.blendMode = .replace
		background.zPosition = -1
		addChild(background)
	}
		}

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

		}

}
