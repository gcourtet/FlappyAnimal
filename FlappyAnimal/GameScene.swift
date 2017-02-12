//
//  GameScene.swift
//  FlappyAnimal
//
//  Created by Guillaume Courtet on 05/02/2017.
//  Copyright © 2017 Guillaume Courtet. All rights reserved.
//

import SpriteKit
import GameplayKit

struct physicsCategory{
    static let Animal : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Rock : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
    //static let Star : UInt32 = 0x1 << 5
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
   
    let defaults = UserDefaults.standard

    var ground = SKSpriteNode()
    var animal = SKSpriteNode()
    var rockPair = SKNode()
    var moveAndRemove = SKAction()
    var moveAndRemoveScore = SKAction()
    
    var score = Int()
    let scoreLabel = SKLabelNode()
    
    var star = Int()
    let starLabel = SKLabelNode()
    
    var starNode = SKSpriteNode()
    
    var restartButton = SKSpriteNode()
    
    var gameStarted = Bool()
    var died = Bool()
    
    func startGame(){
        self.physicsWorld.contactDelegate = self
        
        if(defaults.value(forKey: "star") != nil) {
            star = defaults.value(forKey: "star") as! Int
        } else {
            star = 0
        }
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        background.name = "background"
        background.size = self.size
        self.addChild(background)
        
        ground = SKSpriteNode(imageNamed: "groundGrass")
        ground.position = CGPoint(x: self.frame.width/2, y: ground.frame.height/2)
        ground.zPosition = CGFloat(5)
        let textureGround = SKTexture(imageNamed: "groundGrass")
        ground.physicsBody = SKPhysicsBody(texture: textureGround, alphaThreshold: 0.1, size: ground.size)
        ground.physicsBody?.categoryBitMask = physicsCategory.Ground
        ground.physicsBody?.collisionBitMask = physicsCategory.Animal
        ground.physicsBody?.contactTestBitMask = physicsCategory.Animal
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        self.addChild(ground)
        
        animal = SKSpriteNode(imageNamed: "rabbit")
        animal.setScale(0.3)
        animal.position = CGPoint(x: self.frame.width/2 - animal.size.width/2, y: self.frame.height/2)
        animal.zPosition = CGFloat(3)
        let textureAnimal = SKTexture(imageNamed: "rabbit")
        animal.physicsBody = SKPhysicsBody(texture: textureAnimal, alphaThreshold: 0.1, size: animal.size)
        animal.physicsBody?.categoryBitMask = physicsCategory.Animal
        animal.physicsBody?.collisionBitMask = physicsCategory.Ground | physicsCategory.Rock
        animal.physicsBody?.contactTestBitMask = physicsCategory.Ground | physicsCategory.Rock
        animal.physicsBody?.affectedByGravity = false
        animal.physicsBody?.isDynamic = true
        self.addChild(animal)
        
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = "04b19"
        scoreLabel.zPosition = 5
        scoreLabel.fontSize = 100
        scoreLabel.fontColor = .black
        self.addChild(scoreLabel)
        
        starLabel.position = CGPoint(x: self.frame.width / 10, y: self.frame.height / 2 + self.frame.height / 2.25)
        starLabel.text = "\(star)"
        starLabel.fontName = "04b19"
        starLabel.zPosition = 5
        starLabel.fontSize = 50
        starLabel.fontColor = .black
        self.addChild(starLabel)
        
        starNode = SKSpriteNode(imageNamed: "starGold")
        starNode.position = CGPoint(x: self.frame.width / 20, y: self.frame.height / 2 + self.frame.height / 2.25 + starNode.size.height / 2)
        starNode.zPosition = CGFloat(5)
        self.addChild(starNode)
        
    }
    
    func restartGame(){
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        startGame()
    }
    
    override func didMove(to view: SKView) {
        startGame()
    }

    func createRocks() {
        
        rockPair = SKNode()
        rockPair.name = "rockPair"
        
        let random = Int(arc4random_uniform(10))
        
        
        let topRock = SKSpriteNode(imageNamed: "rockGrass")
        let bottomRock = SKSpriteNode(imageNamed: "rockGrass")
        
        topRock.position = CGPoint(x: self.frame.width + 216, y: self.frame.height/2 + 600)
        topRock.setScale(4)
        topRock.zRotation = CGFloat(M_PI)
        topRock.zPosition = CGFloat(4)
        let texture = SKTexture(imageNamed: "rockGrass")
        topRock.physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.1, size: topRock.size)
        topRock.physicsBody?.categoryBitMask = physicsCategory.Rock
        topRock.physicsBody?.collisionBitMask = physicsCategory.Animal
        topRock.physicsBody?.contactTestBitMask = physicsCategory.Animal | physicsCategory.Score
        topRock.physicsBody?.affectedByGravity = false
        topRock.physicsBody?.isDynamic = false
        
        bottomRock.position = CGPoint(x: self.frame.width + 216, y: self.frame.height/2 - 600)
        bottomRock.setScale(4)
        bottomRock.zPosition = CGFloat(4)
        bottomRock.physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.1, size: bottomRock.size)
        bottomRock.physicsBody?.categoryBitMask = physicsCategory.Rock
        bottomRock.physicsBody?.collisionBitMask = physicsCategory.Animal
        bottomRock.physicsBody?.contactTestBitMask = physicsCategory.Animal | physicsCategory.Score
        bottomRock.physicsBody?.affectedByGravity = false
        bottomRock.physicsBody?.isDynamic = false
        
        let randomHeight = CGFloat(Int(arc4random_uniform(UInt32(400)))) //400 is about less than 0.5 of rock heigth with this scale
        let pairHeightRandom = Int(arc4random_uniform(2))
        switch pairHeightRandom {
        case 0:
            rockPair.position.y = rockPair.position.y + randomHeight
            break
        default:
            rockPair.position.y = rockPair.position.y - randomHeight
            break
        }
        
        switch random {
        case 0...1 :
            rockPair.addChild(topRock)
            break
        case 2...3 :
            rockPair.addChild(bottomRock)
            break
        default :
            rockPair.addChild(topRock)
            rockPair.addChild(bottomRock)
            break
        }
        self.addChild(rockPair)
        rockPair.run(moveAndRemove)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(gameStarted == false){
            
            gameStarted = true
            
            animal.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run {
                () in
                self.createRocks()
            }
            
            let spawnScore = SKAction.run {
                () in
                self.createScore()
            }
            
            let delayScore = SKAction.wait(forDuration: 1.5)

            let spawnDelayScore = SKAction.sequence([spawnScore, delayScore])
            
            let spawnDelayScoreForever = SKAction.repeatForever(spawnDelayScore)
            
            //self.run(spawnDelayScoreForever)
            
            let delay = SKAction.wait(forDuration: 3.5)
            
            let spawnDelay = SKAction.sequence([spawn, delay])
            
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            
            //self.run(spawnDelayForever)
            let testContactAction = SKAction.run {
                self.enumerateChildNodes(withName: "rockPair", using: ({
                    (rock, err) in
                    for i in rock.children {
                        self.enumerateChildNodes(withName: "score", using: ({
                            (node, error) in
                            
                            if(i.intersects(node)) {
                                node.removeFromParent()
                            }
                        }))
                    }
                }))
            }
            
            let testDelay = SKAction.wait(forDuration: 0.1)
            
            let testDelaySequence = SKAction.sequence([testContactAction, testDelay])
            
            let testDelaySequenceForever = SKAction.repeatForever(testDelaySequence)
            
            let allAction = SKAction.group([spawnDelayScoreForever, spawnDelayForever, testDelaySequenceForever])
            self.run(allAction)
            
            let distance = CGFloat(self.frame.width + 864) //864 = 2*rock width with this scale
            let moveRocks = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval((distance - CGFloat(5*score)) * 0.01))
            let removeRocks = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([moveRocks, removeRocks])

            let moveScore = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval((distance - CGFloat(5*score)) * 0.01))
            let removeScore = SKAction.removeFromParent()
            moveAndRemoveScore = SKAction.sequence([moveScore, removeScore])
            
        animal.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        animal.physicsBody?.applyImpulse(CGVector(dx: 0, dy: animal.size.height*1.25))
        } else if(died == false){
            animal.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            animal.physicsBody?.applyImpulse(CGVector(dx: 0, dy: animal.size.height*1.25))
        }
        
        for touch in touches{
            let location = touch.location(in: self)
            
            if died == true{
                if restartButton.contains(location){
                    restartGame()
                    
                }
                
                
            }
            
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        if firstBody.categoryBitMask == physicsCategory.Score && secondBody.categoryBitMask == physicsCategory.Animal {
            firstBody.categoryBitMask = 0
            firstBody.node?.removeFromParent()
            star += 1
            starLabel.text = "\(star)"
            
        } else if firstBody.categoryBitMask == physicsCategory.Animal && secondBody.categoryBitMask == physicsCategory.Score {
            secondBody.categoryBitMask = 0
            secondBody.node?.removeFromParent()
            star += 1
            starLabel.text = "\(star)"
            
        } else if firstBody.categoryBitMask == physicsCategory.Animal && secondBody.categoryBitMask == physicsCategory.Rock || firstBody.categoryBitMask == physicsCategory.Rock && secondBody.categoryBitMask == physicsCategory.Animal {
            
            enumerateChildNodes(withName: "rockPair", using: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            enumerateChildNodes(withName: "score", using: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false{
                died = true
                createRestartButton()
            }
        } else if firstBody.categoryBitMask == physicsCategory.Animal && secondBody.categoryBitMask == physicsCategory.Ground || firstBody.categoryBitMask == physicsCategory.Ground && secondBody.categoryBitMask == physicsCategory.Animal {
            
            enumerateChildNodes(withName: "rockPair", using: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            enumerateChildNodes(withName: "score", using: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false{
                died = true
                createRestartButton()
            }
        }
    }
    
    func createScore() {
        let scoreNode = SKSpriteNode(imageNamed: "starGold")
        scoreNode.name = "score"
        
        let random = Int(arc4random_uniform(2))
        var offset = 0
        switch random {
        case 0:
            offset = Int(arc4random_uniform(UInt32(Int(self.frame.height/3))))
            break
        default:
            offset = -Int(arc4random_uniform(UInt32(Int(self.frame.height/3))))
            break
        }
        
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width + 216, y: self.frame.height / 2 + CGFloat(offset))
        scoreNode.zPosition = CGFloat(4)
        let texture = SKTexture(imageNamed: "starGold")
        scoreNode.physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.1, size: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = physicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = physicsCategory.Animal | physicsCategory.Rock
        self.addChild(scoreNode)
        scoreNode.run(self.moveAndRemoveScore)
    }
    
    func createRestartButton() {
        defaults.set(star, forKey: "star")
        restartButton = SKSpriteNode(imageNamed: "restartButton")
        restartButton.setScale(0)
        restartButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartButton.zPosition = 6
        self.addChild(restartButton)
        restartButton.run(SKAction.scale(to: 0.8, duration: 0.3))
    }
    
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
