//
//  GameScene.swift
//  Project11
//
//  Created by Paul Richardson on 29/04/2021.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {

	let balls = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow",]


	var scoreLabel: SKLabelNode!

	var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}

	var ballsLabel: SKLabelNode!

	var ballsAvailable = 5 {
		didSet {
			ballsLabel.text = "Balls available: \(ballsAvailable)"
		}
	}

	var editLabel: SKLabelNode!

	var editingMode = false {
		didSet {
			if editingMode {
				editLabel.text = "Done"
			} else {
				editLabel.text = "Edit"
			}
		}
	}

	override func didMove(to view: SKView) {
		let background = SKSpriteNode(imageNamed: "background")
		background.position = CGPoint(x: 512, y: 384)
		background.blendMode = .replace
		background.zPosition = -1
		addChild(background)
		physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
		physicsWorld.contactDelegate = self

		makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
		makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
		makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
		makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)

		makeBouncer(at: CGPoint(x: 0, y: 0))
		makeBouncer(at: CGPoint(x: 256, y: 0))
		makeBouncer(at	: CGPoint(x: 512, y: 0))
		makeBouncer(at: CGPoint(x: 768, y: 0))
		makeBouncer(at: CGPoint(x: 1024, y: 0))

		scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.text = "Score: 0"
		scoreLabel.horizontalAlignmentMode = .right
		scoreLabel.position = CGPoint(x: 980, y: 700)
		addChild(scoreLabel)

		ballsLabel = SKLabelNode(fontNamed: "Chalkduster")
		ballsLabel.text = "Balls available: \(ballsAvailable)"
		ballsLabel.horizontalAlignmentMode = .right
		ballsLabel.position = CGPoint(x: 980, y: 650)
		addChild(ballsLabel)

		editLabel = SKLabelNode(fontNamed: "Chalkduster")
		editLabel.text = "Edit"
		editLabel.position = CGPoint(x: 80, y: 700)
		addChild(editLabel)

	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }

		let location = touch.location(in: self)

		let objects = nodes(at: location)

		if objects.contains(editLabel) {
			editingMode.toggle()
		} else {
			if editingMode {
				let size = CGSize(width: Int.random(in: 16...128), height: 16)
				let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
				box.zRotation = CGFloat.random(in: 0...CGFloat.pi)
				box.position = location
				box.name = "box"

				box.physicsBody = SKPhysicsBody(rectangleOf: size)
				box.physicsBody?.isDynamic = false

				addChild(box)

			} else {
				guard ballsAvailable > 0 else {
					return
				}
				let ball = SKSpriteNode(imageNamed: balls.randomElement() ?? "ballRed")
				ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
				ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
				ball.physicsBody?.restitution = 0.4
				ball.position = CGPoint(x: location.x, y: self.size.height)
				ball.name = "ball"
				addChild(ball)
				ballsAvailable -= 1
			}
		}
	}

	fileprivate func makeBouncer(at position: CGPoint) {
		let bouncer = SKSpriteNode(imageNamed: "bouncer")
		bouncer.position = position
		bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
		bouncer.physicsBody?.isDynamic = false
		addChild(bouncer)
	}

	func makeSlot(at position: CGPoint, isGood: Bool) {
		var slotBase: SKSpriteNode
		var slotGlow: SKSpriteNode

		if isGood {
			slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
			slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
			slotBase.name = "good"
		} else {
			slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
			slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
			slotBase.name = "bad"
		}
		slotBase.position = position
		slotGlow.position = position

		slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
		slotBase.physicsBody?.isDynamic = false

		addChild(slotBase)
		addChild(slotGlow)

		let spin = SKAction.rotate(byAngle: CGFloat.pi, duration: 10)
		let spinForever = SKAction.repeatForever(spin)
		slotGlow.run(spinForever)

	}

	func didBegin(_ contact: SKPhysicsContact) {
		guard let nodeA = contact.bodyA.node else { return }
		guard let nodeB = contact.bodyB.node else { return }

		if nodeA.name == "ball" {
			collisionBetween(ball: nodeA, object: nodeB)
		} else if nodeB.name == "ball" {
			collisionBetween(ball: nodeB, object: nodeA)
		}
	}

	func collisionBetween(ball: SKNode, object: SKNode) {
		if object.name == "good" {
			destroy(ball: ball)
			score += 1
		} else if object.name == "bad" {
			destroy(ball: ball)
			score -= 1
		} else if object.name == "box" {
			removeObstacle(box: object)
		}
	}

	func removeObstacle(box: SKNode) {
		ballsAvailable += 1
		if let magicParticles = SKEmitterNode(fileNamed: "MagicParticles") {
			magicParticles.position = box.position
			addChild(magicParticles)
		}
		box.removeFromParent()
	}

	func destroy(ball: SKNode) {
		if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
			fireParticles.position = ball.position
			addChild(fireParticles)
		}
		ball.removeFromParent()
	}

}
