//
//  GameScene.swift
//  TD School Project Shared
//
//  Created by Jack Darlison on 02/09/2019.
//  Copyright © 2019 Jack Darlison. All rights reserved.
//

import SpriteKit

enum bodyTypes:UInt32 {
    case enemy = 0b1
    case bullet = 0b10
}

enum gameVariables:CGFloat {
    case tileSize = 90
    case height = 900
    case width = 1600
    case gameBarWidth = 250
}

enum damageTypes {
    case none
    case projectile
    case fire
    case ice
    case laser
    case electric
    
    var color: UIColor {
        switch self {
        case .none:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .projectile:
            return #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0)
        case .fire:
            return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        case .ice:
            return #colorLiteral(red: 0.7345260981, green: 0.9764705896, blue: 0.9541370781, alpha: 1)
        case .laser:
            return #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        case .electric:
            return #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 1)
        }
    }
}

enum towerTypes {
    case basic
    case fire
    case laser
    case electric
    case ice
    
    var cost: Int {
        switch self {
        case .basic:
            return 50
        case .fire:
            return 100
        case .laser:
            return 200
        case .electric:
            return 150
        case .ice:
            return 100
        }
    }
    
    var createTower: Tower {
        switch self {
        case .basic:
            return BasicTower(texture: SKTexture(imageNamed: "basicTower"),
                              color: .white,
                              size: CGSize(width: gameVariables.tileSize.rawValue, height: gameVariables.tileSize.rawValue))
        case .fire:
            return FireTower(texture: SKTexture(imageNamed: "fireTower"),
                             color: UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1),
                             size: CGSize(width: gameVariables.tileSize.rawValue, height: gameVariables.tileSize.rawValue))
        case .laser:
            return LaserTower(texture: SKTexture(imageNamed: "laserTower"),
                              color: UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1),
                              size: CGSize(width: gameVariables.tileSize.rawValue, height: gameVariables.tileSize.rawValue))
        case .electric:
            return ElectricTower(texture: SKTexture(imageNamed: "electricTower"),
                                 color: UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1),
                                 size: CGSize(width: gameVariables.tileSize.rawValue, height: gameVariables.tileSize.rawValue))
        case .ice:
            return IceTower(texture: SKTexture(imageNamed: "iceTower"),
                            color: UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1),
                            size: CGSize(width: gameVariables.tileSize.rawValue, height: gameVariables.tileSize.rawValue))
        }
    }
}

enum Difficulty {
    case easy
    case medium
    case hard
    
    var getHealthMult: CGFloat {
        switch self {
        case .easy:
            return 1
        case .medium:
            return 1.5
        case .hard:
            return 2
        }
    }
    
    var getSpeedMult: CGFloat {
        switch self {
        case .easy:
            return 1
        case .medium:
            return 1.2
        case .hard:
            return 1.4
        }
    }
    
    var getLetter: String {
        switch self {
        case .easy:
            return "E"
        case .medium:
            return "M"
        case .hard:
            return "H"
        }
    }
}

//MARK: Scene

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var isSet: Bool = false
    
    //waves
    var wavesNumber:Int = 0
    var waveDone: Bool = true
    var wavePosistion: Int = 0
    var numSpawned: Int = 0
    var gameDone:Bool = false
    var manager: SceneManager?
    let userInfo = UserDefaults.standard
    
    //(time between spawn, enemy type, how many), multiple patterns in wave
    let wavesStructure: [[(Double,[damageTypes],Int)]] = [
        [(0.5, [.none], 10)],
        [(0.5, [.projectile], 10)],
        [(0.5, [.fire], 10)],
        [(0.5, [.ice], 10)],
        [(0.5, [.electric], 10)],
        [(0.5, [.laser], 10)],
        [(0.25, [.projectile, .fire, .laser, .electric, .ice], 100)],
        [(0.05, [.projectile, .fire, .laser, .electric, .ice], 10), (0.1, [.projectile, .fire, .laser, .electric, .ice], 20), (0.25, [.projectile, .fire, .laser, .electric, .ice], 40)]
    ]
    var currentSpawnTime: TimeInterval = 0.5 // make first time between ;)
    
    //variables for nodes that will be used from the sks file

    var whichMap: Int = 0
    var map:SKTileMapNode?
    var path:Path?
    
    // timing variables.
    
    var lastTime:TimeInterval = 0
    var lastspawn:TimeInterval = 0
    
    //game variables
    
    var difficulty: Difficulty = .easy
    var money:Int = 1000
    var score:Int = 0
    var lives:Int = 10
    let moneyNode: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
    let livesNode:SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
    let scoreNode:SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit
        
        return scene
    }
    
    func setUpScene() {
        
        isSet = true
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        if whichMap == 0 {
            if self.path == nil && self.map == nil {
            
                let gameWidth = gameVariables.width.rawValue - gameVariables.gameBarWidth.rawValue
                let rowAmount = Int(gameVariables.height.rawValue/gameVariables.tileSize.rawValue)
                let columnAmount = Int(gameWidth/gameVariables.tileSize.rawValue)
                
                path = Path(_rows: rowAmount, _columns: columnAmount)
                let tileSet = SKTileSet(named: "Maze")!
                let grassTile = tileSet.tileGroups.first(where: {$0.name == "wall\(Int(gameVariables.tileSize.rawValue))"})
                let tileMap = SKTileMapNode(tileSet: tileSet, columns: columnAmount, rows: rowAmount,
                                            tileSize: CGSize(width: gameVariables.tileSize.rawValue,
                                                             height: gameVariables.tileSize.rawValue))
                for row in 0..<path!.grid.count {
                    for column in 0..<path!.grid[row].count {
                        if path!.grid[row][column] == 0 {
                            tileMap.setTileGroup(grassTile, forColumn: column, row: row)
                        }
                    }
                }

                tileMap.position = CGPoint(x: -gameVariables.gameBarWidth.rawValue/2, y: 0)
                tileMap.zPosition = -1
                map = tileMap
            }
            
            if map?.parent != nil {
                map?.removeFromParent()
            }
            self.addChild(map!)
        } else if whichMap == 1 {
            self.map = self.childNode(withName: "map\(whichMap)") as? SKTileMapNode
        } else if whichMap == 2 {
            self.map = self.childNode(withName: "map\(whichMap)") as? SKTileMapNode
        } else if whichMap == 3 {
            self.map = self.childNode(withName: "map\(whichMap)") as? SKTileMapNode
        }
        self.map?.position = CGPoint(x: -125, y: 0)


        print(self.children)
        
        if let tester:TowerButton = self.childNode(withName: "basicTowerButton") as? TowerButton {
            print("tower created")
            tester.whichTower = towerTypes.basic
        } else {
            print("tower button not created")
        }
        
        if let tester:TowerButton = self.childNode(withName: "laserTowerButton") as? TowerButton {
            print("tower created")
            tester.whichTower = towerTypes.laser
        } else {
            print("tower button not created")
        }
        
        if let tester:TowerButton = self.childNode(withName: "fireTowerButton") as? TowerButton {
            print("tower created")
            tester.whichTower = towerTypes.fire
        } else {
            print("tower button not created")
        }
        
        if let tester:TowerButton = self.childNode(withName: "electricTowerButton") as? TowerButton {
            print("tower created")
            tester.whichTower = towerTypes.electric
        } else {
            print("tower button not created")
        }
        
        if let tester:TowerButton = self.childNode(withName: "iceTowerButton") as? TowerButton {
            print("tower created")
            tester.whichTower = towerTypes.ice
        } else {
            print("tower button not created")
        }
        
//        if let tester:SKTileMapNode = self.childNode(withName: "Map1") as? SKTileMapNode {
//            print("map created")
//            map = tester
//        } else {
//            print("map not created")
//        }
        
        if let tester:Button = self.childNode(withName: "nextWaveButton") as? Button {
            print("next wave button created")
            let nextWaveButton = tester
            nextWaveButton.buttonAction = {self.waveDone = false}
        } else {
            print("next wave button not created")
        }
        
        if let tester:Button = self.childNode(withName: "pauseButton") as? Button {
            print("pause button created")
            let pauseButton = tester
            pauseButton.buttonAction = {
                self.isPaused = true
                self.physicsWorld.speed = 0
                self.manager?.pauseGame(_which: .pause)
            }
        } else {
            print("pause not created")
        }
        
        //label creation
        
        scoreNode.text = "Score: \(score)"
        scoreNode.fontSize = 30
        scoreNode.fontColor = SKColor.black
        scoreNode.horizontalAlignmentMode = .right
        scoreNode.position = CGPoint(x: 550, y: frame.maxY-30)
        
        addChild(scoreNode)
        
        moneyNode.text = "Money: \(money)"
        moneyNode.fontSize = 30
        moneyNode.fontColor = SKColor.black
        moneyNode.horizontalAlignmentMode = .right
        moneyNode.position = CGPoint(x: 550, y: frame.maxY-60)
        
        addChild(moneyNode)
        
        livesNode.text = "Lives: \(lives)"
        livesNode.fontSize = 30
        livesNode.fontColor = SKColor.black
        livesNode.horizontalAlignmentMode = .right
        livesNode.position = CGPoint(x: 550, y: frame.maxY-90)
        
        addChild(livesNode)
        
    }
    
    override func didMove(to view: SKView) {
        
        print("moved to game scene view")
        
        self.isPaused = false
        self.physicsWorld.speed = 1
        
        if !isSet {
           self.setUpScene()
        }
    }
}

//MARK: iOS Controls

#if os(iOS)

// Touch-based event handling

extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        _ = touch.location(in: self)
        
        (self.childNode(withName: "towerMenu") as? GameBar)?.rangeIndicator?.removeFromParent()
        self.childNode(withName: "towerMenu")?.removeFromParent()
    }

}
#endif

//MARK: macOS Controls

#if os(OSX)

// Mouse-based event handling

extension GameScene {
    override func mouseDown(with event: NSEvent) {
        //nothing
    }
}
#endif

//MARK: physics

extension GameScene {
    func didBegin(_ contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask == bodyTypes.bullet.rawValue && contact.bodyB.categoryBitMask == bodyTypes.enemy.rawValue) {
            let E:Enemies = contact.bodyB.node as! Enemies
            let B: Bullet = contact.bodyA.node as! Bullet
            let isDead = E.hit(dmg: B.damage, dmgType: B.dmgType)
            if isDead {
                B.parentTower.kills += 1
            }
            if B.parentTower is FireTower {
                (B.parentTower as! FireTower).applyDot(enemy: E)
            } else if B.parentTower is IceTower {
                (B.parentTower as! IceTower).applySlow(enemy: E)
            }
            B.removeFromParent()
        } else if (contact.bodyA.categoryBitMask == bodyTypes.enemy.rawValue && contact.bodyB.categoryBitMask == bodyTypes.bullet.rawValue) {
            let E:Enemies = contact.bodyA.node as! Enemies
            let B: Bullet = contact.bodyB.node as! Bullet
            let isDead = E.hit(dmg: B.damage, dmgType: B.dmgType)
            if isDead {
                B.parentTower.kills += 1
            }
            if B.parentTower is FireTower {
                (B.parentTower as! FireTower).applyDot(enemy: E)
            } else if B.parentTower is IceTower {
                (B.parentTower as! IceTower).applySlow(enemy: E)
            }
            B.removeFromParent()
        }
    }
}

//MARK: Frame Updates

extension GameScene {
    
    override func update(_ currentTime: TimeInterval) {
        
        // removes nodes that are outside of the scenes boundaries.
        
        for child in self.children {
            if self.frame.contains(child.position) == false {
                child.removeFromParent()
            } else if child is Enemies && child.position.x>550 {
                child.removeFromParent()
                lives += -1
            }
        }
        
        // end game
        let highScore = userInfo.integer(forKey: "highscore")
        
        if lives < 1 {
            if score > highScore {
                userInfo.set(score, forKey: "highscore")
            }
            manager?.pauseGame(_which: .end)
        }
        
        if gameDone {
            if score > highScore {
                userInfo.set(score, forKey: "highscore")
            }
            userInfo.set("completed", forKey: "map\(whichMap)")
            manager?.pauseGame(_which: .win)
        }
        
        //keeps track of time
        
        let deltaTime = currentTime - lastTime
        //let currentFPS = 1/deltaTime
        lastTime = currentTime
        
        //spawning
        
        
        if gameDone == false {
            if waveDone == false {
                if lastspawn > currentSpawnTime {
                    if numSpawned < wavesStructure[wavesNumber][wavePosistion].2 {
                        let enemy = Enemies(texture: SKTexture(imageNamed: "enemy1"),
                                            color: UIColor(displayP3Red: 0.2, green: 0.2, blue: 0.6, alpha: 1),
                                            size: CGSize(width: gameVariables.tileSize.rawValue, height: gameVariables.tileSize.rawValue),
                                            _path: self.path?.path,
                                            _types: wavesStructure[wavesNumber][wavePosistion].1,
                                            _dif: self.difficulty,
                                            _map: self.whichMap,
                                            _wave: CGFloat(wavesNumber))
                        numSpawned += 1
                        self.addChild(enemy)
                        lastspawn = 0
                    } else {
                        numSpawned = 0
                        wavePosistion += 1
                        if wavePosistion >= wavesStructure[wavesNumber].count {
                            wavesNumber += 1
                            wavePosistion = 0
                            waveDone = true
                        }
                        if wavesNumber >= wavesStructure.count {
                            print("level finished")
                            gameDone = true
                        } else {
                            currentSpawnTime = wavesStructure[wavesNumber][wavePosistion].0
                        }
                    }

                } else {
                    lastspawn += deltaTime
                }
            }
        }
        
        
        // loops through scene for objects to update
        
        for child in self.children {
            
            if child is Tower && (child as? Tower)?.placed == true{
                
                let closest = nearestNode(node: child)
                
                if closest.node != nil {
                    (child as? Tower)?.update(closest: closest.node!, dist: closest.dist, deltaTime: deltaTime)
                }
            } /* else if child is Bullet {
                (child as! Bullet).update(deltaTime: deltaTime)
            } */
        }
        
        //update labels
        
        self.scoreNode.text = "Score: \(score)"
        self.livesNode.text = "lives: \(lives)"
        self.moneyNode.text = "money: \(money)"
        
        if self.childNode(withName: "towerMenu") != nil {
           (self.childNode(withName: "towerMenu") as! GameBar).update()
        }
    }
}

//MARK: functions

extension GameScene {
    
    // use of pythagoras to achieve a single distance between two nodes
    
    func distance(node:CGPoint, target:CGPoint) -> CGFloat {
        let dist:CGFloat = sqrt((target.x-node.x)*(target.x-node.x) + (target.y-node.y)*(target.y-node.y))
        
        return dist
    }
    
    // this takes the scene and cycles through the children of it taking the distance from the base node to each other node. returns closest node.
    
    func nearestNode(node:SKNode) -> (node: SKNode?, dist: CGFloat) {
        
        var shortestNode:SKNode?
        var shortest:CGFloat = CGFloat.infinity
        
        for child in self.children {
            let dis = distance(node: node.position, target: child.position)
            if dis < shortest && child is Enemies && dis != 0 {
                shortestNode = child
                shortest = dis
            }
            
        }
        return (shortestNode, shortest)
    }
    
}

