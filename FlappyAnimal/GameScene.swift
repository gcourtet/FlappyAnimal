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
    static let Star : UInt32 = 0x1 << 5
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let defaults = UserDefaults.standard

    var ground = SKSpriteNode()
    var animal = SKSpriteNode()
    var rockPair = SKNode()
    var moveAndRemove = SKAction()
    var moveAndRemoveStar = SKAction()
    
    var highScore = Int()
    var score = Int()
    let scoreLabel = SKLabelNode()
    
    var timer = Int()
    var countdown = Timer()
    
    var star = Int()
    let starCountLabel = SKLabelNode()
    var starCountNode = SKSpriteNode()
    
    var restartButton = SKSpriteNode()
    var restartBackGround = SKSpriteNode()
    
    var gameStarted = Bool()
    var died = Bool()
    
    var title = SKLabelNode()
    
    let tapToStart = SKLabelNode()
    
    var tapTick = SKSpriteNode()
    
    var bestScore = Int()
    let bestScoreLabel = SKLabelNode()
    var bestScoreNode = SKSpriteNode()
    
    var pauseButtonNode = SKSpriteNode()
    
    var shopButtonNode = SKSpriteNode()
    var shopCloseButton = SKSpriteNode()
    var shopBackground = SKSpriteNode()
    
    var label = SKLabelNode()
    
    var isPlaying = Bool()
    
    var canPlay = Bool()
    
    var isShopping = Bool()
    
    var shopText = SKLabelNode()
    
    func startGame(){
        self.physicsWorld.contactDelegate = self
        
        if(defaults.value(forKey: "star") != nil) {
            star = defaults.value(forKey: "star") as! Int
        } else {
            star = 0
        }
        
        if(defaults.value(forKey: "best") != nil) {
            bestScore = defaults.value(forKey: "best") as! Int
        } else {
            bestScore = 0
        }
        
        canPlay = true
        isShopping = false
        isPlaying = false
        
        title = SKLabelNode()
        title.text = "Flappy Animal"
        title.fontName = "04b19"
        title.zPosition = 40
        title.fontSize = 100
        title.fontColor = .red
        title.position = CGPoint(x: self.frame.width/2, y: 2 * self.frame.height/3)
        title.zRotation = CGFloat(M_PI/8)
        self.addChild(title)
        
        tapToStart.text = "Tap to start"
        tapToStart.fontName = "04b19"
        tapToStart.zPosition = 40
        tapToStart.fontSize = 50
        tapToStart.fontColor = .darkGray
        tapToStart.position = CGPoint(x: self.frame.width/2, y: self.frame.height/3)
        self.addChild(tapToStart)
        
        tapTick = SKSpriteNode(imageNamed: "tapTick")
        tapTick.setScale(2)
        tapTick.position = CGPoint(x: self.frame.width/2, y: self.frame.height/4)
        tapTick.zPosition = 40

        
        let bigger = SKAction.scale(to: 2.5, duration: 0.75)
        let smaller = SKAction.scale(to: 1.5, duration: 0.75)
        let tickAnimSequence = SKAction.sequence([bigger, smaller])
        let tickAnim = SKAction.repeatForever(tickAnimSequence)
        
        tapTick.run(tickAnim)
        self.addChild(tapTick)
        
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
        
        starCountNode = SKSpriteNode(imageNamed: "starGold")
        starCountNode.position = CGPoint(x: self.frame.width/20, y: self.frame.height / 2 + self.frame.height / 2.25 + starCountNode.size.height / 2)
        starCountNode.zPosition = CGFloat(5)
        self.addChild(starCountNode)
        
        starCountLabel.position = CGPoint(x: starCountNode.position.x + starCountNode.size.width/2 + 10, y: self.frame.height / 2 + self.frame.height / 2.25)
        starCountLabel.text = "\(star)"
        starCountLabel.horizontalAlignmentMode = .left
        starCountLabel.fontName = "04b19"
        starCountLabel.zPosition = 5
        starCountLabel.fontSize = 50
        starCountLabel.fontColor = .black
        self.addChild(starCountLabel)
        
        bestScoreNode = SKSpriteNode(imageNamed: "bestScore")
        bestScoreNode.size = starCountNode.size
        bestScoreNode.position = CGPoint(x: self.frame.width/20, y: self.frame.height / 2 + self.frame.height / 2.5 + bestScoreNode.size.height / 2)
        bestScoreNode.zPosition = CGFloat(5)
        self.addChild(bestScoreNode)
        
        bestScoreLabel.position = CGPoint(x: bestScoreNode.position.x + bestScoreNode.size.width/2 + 10, y: self.frame.height / 2 + self.frame.height / 2.5)
        bestScoreLabel.text = "\(bestScore)"
        bestScoreLabel.horizontalAlignmentMode = .left
        bestScoreLabel.fontName = "04b19"
        bestScoreLabel.zPosition = 5
        bestScoreLabel.fontSize = 50
        bestScoreLabel.fontColor = .black
        self.addChild(bestScoreLabel)
        
        shopButtonNode = SKSpriteNode(imageNamed: "shopButton")
        shopButtonNode.setScale(0.75)
        shopButtonNode.position = CGPoint(x: self.frame.width/2, y: shopButtonNode.size.height/2 + 5)
        shopButtonNode.zPosition = 10
        self.addChild(shopButtonNode)
        
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
        let scoreNode = SKSpriteNode()
        
        topRock.position = CGPoint(x: self.frame.width + 216, y: self.frame.height/2 + 600)
        topRock.setScale(4)
        topRock.zRotation = CGFloat(M_PI)
        topRock.zPosition = CGFloat(4)
        let texture = SKTexture(imageNamed: "rockGrass")
        topRock.physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.1, size: topRock.size)
        topRock.physicsBody?.categoryBitMask = physicsCategory.Rock
        topRock.physicsBody?.collisionBitMask = physicsCategory.Animal
        topRock.physicsBody?.contactTestBitMask = physicsCategory.Animal | physicsCategory.Star
        topRock.physicsBody?.affectedByGravity = false
        topRock.physicsBody?.isDynamic = false
        
        bottomRock.position = CGPoint(x: self.frame.width + 216, y: self.frame.height/2 - 600)
        bottomRock.setScale(4)
        bottomRock.zPosition = CGFloat(4)
        bottomRock.physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.1, size: bottomRock.size)
        bottomRock.physicsBody?.categoryBitMask = physicsCategory.Rock
        bottomRock.physicsBody?.collisionBitMask = physicsCategory.Animal
        bottomRock.physicsBody?.contactTestBitMask = physicsCategory.Animal | physicsCategory.Star
        bottomRock.physicsBody?.affectedByGravity = false
        bottomRock.physicsBody?.isDynamic = false
        
        scoreNode.size = CGSize(width: 1, height: self.frame.height*2)
        scoreNode.position = CGPoint(x: self.frame.width + 216, y: self.frame.height/2)
        scoreNode.zPosition = CGFloat(3.9)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = physicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = physicsCategory.Animal
        rockPair.addChild(scoreNode)
        
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
        
        for touch in touches{
            let location = touch.location(in: self)
            if(isShopping && shopCloseButton.contains(location)){
                shopCloseButton.removeFromParent()
                shopText.removeFromParent()
                shopBackground.run(SKAction.scale(to: 0, duration: 0.1), completion: {() -> () in self.shopBackground.removeFromParent()})
                isShopping = false
                canPlay = true
            } else if(gameStarted == false && shopButtonNode.contains(location) && !isShopping){
                print("Entering shop")
                canPlay = false
                isShopping = true
                shopBackground = SKSpriteNode(imageNamed: "restartPane")
                shopBackground.size = CGSize(width: self.frame.width+20, height: self.frame.height+20)
                shopBackground.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
                shopBackground.zPosition = 100
                self.addChild(shopBackground)
                
                shopCloseButton = SKSpriteNode(imageNamed: "closeButton")
                shopCloseButton.setScale(0.4)
                shopCloseButton.position = CGPoint(x: self.frame.width - shopCloseButton.size.width/2, y: self.frame.height - shopCloseButton.size.height/2)
                shopCloseButton.zPosition = 110
                self.addChild(shopCloseButton)
                
                shopText.text = "Available\nsoon"
                shopText.fontName = "04b19"
                shopText.zPosition = 110
                shopText.fontSize = 50
                shopText.fontColor = .black
                shopText.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
                self.addChild(shopText)
        
            } else if(gameStarted == false && !shopButtonNode.contains(location) && canPlay){
                
                gameStarted = true
                isPlaying = true
                
                self.tapToStart.removeFromParent()
                self.tapTick.removeFromParent()
                self.title.removeFromParent()
                self.shopButtonNode.removeFromParent()
                
                scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
                scoreLabel.text = "\(score)"
                scoreLabel.fontName = "04b19"
                scoreLabel.zPosition = 5
                scoreLabel.fontSize = 100
                scoreLabel.fontColor = .black
                self.addChild(scoreLabel)
                
                pauseButtonNode = SKSpriteNode(imageNamed: "pauseButton")
                pauseButtonNode.setScale(0.5)
                pauseButtonNode.position = CGPoint(x: pauseButtonNode.size.width/2 + 10, y: pauseButtonNode.size.height/2 + 5)
                pauseButtonNode.zPosition = 10
                self.addChild(pauseButtonNode)
                
                animal.physicsBody?.affectedByGravity = true
                
                let spawn = SKAction.run {
                    () in
                    self.createRocks()
                }
                
                let spawnStar = SKAction.run {
                    () in
                    self.createStar()
                }
                
                let delayStar = SKAction.wait(forDuration: 1.5)
                
                let spawnDelayStar = SKAction.sequence([spawnStar, delayStar])
                
                let spawnDelayStarForever = SKAction.repeatForever(spawnDelayStar)
                
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
                
                let allAction = SKAction.group([spawnDelayStarForever, spawnDelayForever, testDelaySequenceForever])
                self.run(allAction)
                
                let distance = CGFloat(self.frame.width + 864) //864 = 2*rock width with this scale
                let moveRocks = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(distance * 0.01))
                let removeRocks = SKAction.removeFromParent()
                moveAndRemove = SKAction.sequence([moveRocks, removeRocks])
                
                let moveStar = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(distance * 0.01))
                let removeStar = SKAction.removeFromParent()
                moveAndRemoveStar = SKAction.sequence([moveStar, removeStar])
                
                animal.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                animal.physicsBody?.applyImpulse(CGVector(dx: 0, dy: animal.size.height*1.25))
            } else if(!pauseButtonNode.contains(location) && died == false && gameStarted == true && animal.position.y < self.frame.height){
                animal.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                animal.physicsBody?.applyImpulse(CGVector(dx: 0, dy: animal.size.height*1.25))
            } else if (died == true) {
                if restartButton.contains(location){
                    restartGame()
                }
            } else if(pauseButtonNode.contains(location) && /*scene?.physicsWorld.speed == 0*/ self.speed == 0 && isPlaying == false && timer == -1) {
                timer = 3
                label.text = "\(timer)"
                label.fontName = "04b19"
                label.zPosition = 40
                label.fontSize = 200
                label.fontColor = .darkGray
                label.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
                self.addChild(label)
                self.pauseButtonNode.removeFromParent()
                //print(timer)
                    countdown = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timeLeft), userInfo: nil, repeats: true)
//
//                var counter = 3
//                let timerLabel = SKLabelNode()
//                timerLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
//                timerLabel.fontName = "04b19"
//                timerLabel.text = "\(counter)"
//                timerLabel.zPosition = 50
//                timerLabel.fontSize = 150
//                timerLabel.color = .red
//                self.addChild(timerLabel)
//                print("yp")
//                let waitAction = SKAction.wait(forDuration: 1.0)
//                let timerAction = SKAction.run({
//                    if counter > 0 {
//                        timerLabel.text = "\(counter)"
//                        counter -= 1
//                    } else {
//                        self.removeAction(forKey: "timerForever")
//                    }
//                })
//                let timer = SKAction.sequence([waitAction, timerAction])
//                let timerForever = SKAction.repeatForever(timer)
//                self.run(timerForever, withKey: "timerForever")
//                timerLabel.removeFromParent()

            } else if(pauseButtonNode.contains(location) && isPlaying == true) {
                timer = -1
                isPlaying = false
                self.speed = 0
                //self.isPaused = true
                scene?.physicsWorld.speed = 0
                pauseButtonNode.removeFromParent()
                pauseButtonNode = SKSpriteNode(imageNamed: "playButton")
                pauseButtonNode.setScale(0.5)
                pauseButtonNode.position = CGPoint(x: pauseButtonNode.size.width/2 + 10, y: pauseButtonNode.size.height/2 + 5)
                pauseButtonNode.zPosition = 10
                self.addChild(pauseButtonNode)
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        if firstBody.categoryBitMask == physicsCategory.Score && secondBody.categoryBitMask == physicsCategory.Animal {
            firstBody.categoryBitMask = 0
            firstBody.node?.removeFromParent()
            score += 1
            scoreLabel.text = "\(score)"
            /* let distance = CGFloat(self.frame.width + 864) //864 = 2*rock width with this scale
            let moveRocks = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval((distance - CGFloat(score * 50)) * 0.01))
            let removeRocks = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([moveRocks, removeRocks])
            
            let moveStar = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval((distance - CGFloat(score * 50)) * 0.01))
            let removeStar = SKAction.removeFromParent()
            moveAndRemoveStar = SKAction.sequence([moveStar, removeStar]) */

        } else if firstBody.categoryBitMask == physicsCategory.Animal && secondBody.categoryBitMask == physicsCategory.Score {
            secondBody.categoryBitMask = 0
            secondBody.node?.removeFromParent()
            score += 1
            scoreLabel.text = "\(score)"
            if(score > bestScore) {
                bestScore = score
                bestScoreLabel.text = "\(bestScore)"
            }

        } else if firstBody.categoryBitMask == physicsCategory.Star && secondBody.categoryBitMask == physicsCategory.Animal {
            firstBody.categoryBitMask = 0
            firstBody.node?.removeFromParent()
            star += 1
            starCountLabel.text = "\(star)"
            if(score > bestScore) {
                bestScore = score
                bestScoreLabel.text = "\(bestScore)"
            }
            
        } else if firstBody.categoryBitMask == physicsCategory.Animal && secondBody.categoryBitMask == physicsCategory.Star {
            secondBody.categoryBitMask = 0
            secondBody.node?.removeFromParent()
            star += 1
            starCountLabel.text = "\(star)"
            
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
                pauseButtonNode.removeFromParent()
                createRestartScreen()
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
                pauseButtonNode.removeFromParent()
                createRestartScreen()
            }
        }
        }
    
    func createStar() {
        let starNode = SKSpriteNode(imageNamed: "starGold")
        starNode.name = "score"
        
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
        
        starNode.size = CGSize(width: 50, height: 50)
        starNode.position = CGPoint(x: self.frame.width + 216, y: self.frame.height / 2 + CGFloat(offset))
        starNode.zPosition = CGFloat(4)
        let texture = SKTexture(imageNamed: "starGold")
        starNode.physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.1, size: starNode.size)
        starNode.physicsBody?.affectedByGravity = false
        starNode.physicsBody?.isDynamic = false
        starNode.physicsBody?.categoryBitMask = physicsCategory.Star
        starNode.physicsBody?.collisionBitMask = 0
        starNode.physicsBody?.contactTestBitMask = physicsCategory.Animal | physicsCategory.Rock
        self.addChild(starNode)
        starNode.run(self.moveAndRemoveStar)
    }
    
    func createRestartScreen() {
        defaults.set(star, forKey: "star")
        defaults.set(bestScore, forKey: "best")
        restartBackGround = SKSpriteNode(imageNamed: "restartPane")
        restartBackGround.setScale(0)
        restartBackGround.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBackGround.zPosition = 25
        
        let gameOver = SKLabelNode()
        gameOver.text = "Game over"
        gameOver.fontName = "04b19"
        gameOver.zPosition = 35
        gameOver.fontSize = 60
        gameOver.fontColor = .black
        gameOver.position = CGPoint(x: self.frame.width/2, y: self.frame.height*3/5)
        
        let scoreRestart = SKLabelNode()
        scoreRestart.text = "Score : \(score)"
        scoreRestart.fontName = "04b19"
        scoreRestart.zPosition = 35
        scoreRestart.fontSize = 50
        scoreRestart.fontColor = .black
        scoreRestart.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        restartButton = SKSpriteNode(imageNamed: "restartButton")
        restartButton.setScale(0.8)
        restartButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2.5)
        restartButton.zPosition = 30
        self.addChild(restartBackGround)
        restartBackGround.run(SKAction.scale(to: 2, duration: 0.3), completion:
            { () -> () in
                self.addChild(gameOver)
                self.addChild(scoreRestart)
                self.addChild(self.restartButton)
        })
    }
    
    func timeLeft() {
        if(timer > 1){
            timer -= 1
            label.text = "\(timer)"
        } else {
            label.text = ("GO!")
            countdown.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.speed = 1
                //self.isPaused = false
                self.scene?.physicsWorld.speed = 1
                self.pauseButtonNode = SKSpriteNode(imageNamed: "pauseButton")
                self.pauseButtonNode.setScale(0.5)
                self.pauseButtonNode.position = CGPoint(x: self.pauseButtonNode.size.width/2 + 10, y: self.pauseButtonNode.size.height/2 + 5)
                self.pauseButtonNode.zPosition = 10
                
                self.addChild(self.pauseButtonNode)
                self.label.removeFromParent()
                self.isPlaying = true
                self.timer = -1
            })
        }
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
