//
//  Tower.swift
//  TD School Project
//
//  Created by Jack Darlison on 13/09/2019.
//  Copyright © 2019 Jack Darlison. All rights reserved.
//

import Foundation
import SpriteKit

//MARK: Super class

class Tower: SKSpriteNode {
    
    var upgrades: [Int] = [0,0,0,0] {
        didSet {
            upgradeAmount = 0
            for val in upgrades {
                upgradeAmount += val
            }
        }
    }
    var upgradeAmount: Int = 0
    var upgradeCost: Int = 50
    var type: towerTypes = .basic
    var damage: CGFloat = 5
    var attackSpeed: CGFloat = 0.3
    var bulletSpeed: CGFloat = 2.2
    var lastAttack: CGFloat = 0
    var actualPos: CGPoint?
    var placed: Bool = false
    var range: CGFloat = 300
    var kills:Int = 0
    var spread:Float = 36
    var bulletLifeTime: TimeInterval = 10
    var dmgType: damageTypes = .projectile
    var specialValue: CGFloat = 0
    
    var turretHandler: SKSpriteNode = SKSpriteNode()
    
    // This is required if using this class in an SKS file
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //inititalises the class along with its superclass with the basic information it currently needs.
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.isUserInteractionEnabled = true
        print("tower created from class")
        self.name = "tower"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let towerMenu = GameBar(texture: nil, color: UIColor(displayP3Red: 0.7, green: 0.7, blue: 0.7, alpha: 1), size: CGSize(width: 250, height: gameVariables.height.rawValue), _parentNode: self, _game: self.parent! as! GameScene)
        towerMenu.name = "towerMenu"
        if self.parent?.childNode(withName: "towerMenu") != nil {
            (self.parent?.childNode(withName: "towerMenu") as? GameBar)?.rangeIndicator!.removeFromParent()
            self.parent?.childNode(withName: "towerMenu")?.removeFromParent()
        }
        self.parent?.addChild(towerMenu)
    }

    // creates the turret part of a tower add adds it to the correct place as a child of the main body.
    
    func addTurret(_texture: SKTexture) {
        let turret: SKSpriteNode = SKSpriteNode(texture: _texture, size: CGSize(width: gameVariables.tileSize.rawValue, height: gameVariables.tileSize.rawValue))
        turret.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        turret.position = CGPoint(x: 0,y: 0)
        turret.name = "turret"
        turret.zPosition = 1
        self.addChild(turret)
        turretHandler = turret
        
    }
    
    func shoot() {
        let bullet:Bullet = Bullet(circleOfRadius: 5, _damage: damage, _parentTower: self, _maxTimeOfLife: bulletLifeTime, _dmgType: dmgType)
        self.parent?.addChild(bullet)
        bullet.position = turretHandler.convert(CGPoint(x: 0, y:turretHandler.size.height), to: self.parent!)
        let random: CGFloat = CGFloat(Float.random(in: -Float.pi/spread...Float.pi/spread))
        bullet.physicsBody?.applyImpulse(CGVector(dx: cos(turretHandler.zRotation + CGFloat.pi/2 + random)*bulletSpeed, dy: sin(turretHandler.zRotation + CGFloat.pi/2 + random)*bulletSpeed))
        
    }
    
    func update(closest: SKNode, dist: CGFloat, deltaTime: TimeInterval) {
        if dist < self.range {
        
            let angle = atan2((self.position.y-closest.position.y) , (self.position.x-closest.position.x))
        
            let face = SKAction.rotate(toAngle: angle + CGFloat.pi/2 , duration: 0)
        
            self.childNode(withName: "turret")?.run(face)
        
            if self.lastAttack > self.attackSpeed {
                    self.shoot()
                    self.lastAttack = 0
            } else {
                self.lastAttack += CGFloat(deltaTime)
            }
        }
    }
}

// for basic tower
class Bullet: SKShapeNode {
    
    var dmgType: damageTypes
    var damage: CGFloat
    var parentTower: Tower
    let maxTimeOfLife: TimeInterval
    
    init(circleOfRadius: CGFloat, _damage: CGFloat, _parentTower:Tower, _maxTimeOfLife: TimeInterval, _dmgType: damageTypes){
        dmgType = _dmgType
        maxTimeOfLife = _maxTimeOfLife
        damage = _damage
        parentTower = _parentTower
        super.init()
        
        let life = SKAction.wait(forDuration: maxTimeOfLife)
        let death = SKAction.removeFromParent()
        self.run(SKAction.sequence([life,death]))
        
        self.path = CGPath(ellipseIn: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: circleOfRadius*2, height: circleOfRadius*2)), transform: nil)
        self.fillColor = SKColor.blue
        self.physicsBody = SKPhysicsBody(circleOfRadius: circleOfRadius)
        self.physicsBody?.categoryBitMask = bodyTypes.bullet.rawValue
        self.physicsBody?.collisionBitMask = bodyTypes.enemy.rawValue
        self.physicsBody?.contactTestBitMask = bodyTypes.enemy.rawValue
        self.physicsBody?.friction = 0
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("no coder")
    }
    
    func update(deltaTime: TimeInterval) {
        //nothing
    }
        
}

//MARK: BasicTower

class BasicTower: Tower {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.name = "Basic Tower"
        addTurret(_texture: SKTexture(imageNamed: "basicTowerTurret"))
    }
    
    override func shoot() {
        super.shoot()
    }
}

//MARK: LaserTower

class LaserTower: Tower {
    
    var laserLifeCount: TimeInterval = 0
    let laserLife: TimeInterval = 0.1
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.name = "Laser Tower"
        self.damage = 10
        self.attackSpeed = 1
        self.dmgType = .laser
        self.type = .laser
        addTurret(_texture: SKTexture(imageNamed: "laserTowerTurret"))
    }
    
    override func shoot() {
        let laser = SKSpriteNode(texture: nil, color: SKColor(displayP3Red: 0, green: 0.5, blue: 1.0, alpha: 0), size: CGSize(width: self.size.width*(4/5), height: self.range))
        laser.anchorPoint = CGPoint(x: 0.5, y: 0-((self.size.height/2)/self.range))
        laser.zRotation = (self.childNode(withName: "turret")?.zRotation)!
        laser.name = "laser"
        self.addChild(laser)
        
        for child in (self.parent?.children)! {
            if child is Enemies {
                if child.intersects(laser) {
                    laser.color = SKColor(displayP3Red: 0, green: 0.5, blue: 1.0, alpha: 0.4)
                    if (child as! Enemies).hit(dmg: self.damage, dmgType: dmgType) {
                        self.kills += 1
                    }
                }
            }
        }
        
        let life =  SKAction.wait(forDuration: laserLife)
        let death = SKAction.removeFromParent()
        let lifeNDeath = SKAction.sequence([life,death])
        laser.run(lifeNDeath)
    }
    
    override func update(closest: SKNode, dist: CGFloat, deltaTime: TimeInterval) {
        if dist < self.range {
            
            let angle = atan2((self.position.y-closest.position.y) , (self.position.x-closest.position.x))
            var face:SKAction = SKAction.fadeAlpha(to: 1, duration: 0)
            let offset:CGFloat = CGFloat.pi/2
            if -CGFloat.pi/4 < angle && CGFloat.pi/4 > angle {
                face = SKAction.rotate(toAngle: 0 + offset, duration: 0)
            } else if CGFloat.pi/4 < angle && CGFloat.pi*(3/4) > angle {
                face = SKAction.rotate(toAngle: CGFloat.pi/2 + offset, duration: 0)
            } else if -CGFloat.pi*(3/4) > angle || CGFloat.pi*(3/4) < angle {
                face = SKAction.rotate(toAngle: CGFloat.pi + offset, duration: 0)
            } else if -CGFloat.pi/4 > angle && -CGFloat.pi*(3/4) < angle {
                face = SKAction.rotate(toAngle: -CGFloat.pi/2 + offset, duration: 0)
            }
            self.childNode(withName: "turret")?.run(face)
            
            if self.lastAttack > self.attackSpeed {
                self.shoot()
                self.lastAttack = 0
            } else {
                self.lastAttack += CGFloat(deltaTime)
            }
        }
    }
}

//MARK: fireTower

class FireTower: Tower {
    
    let dotDmg: CGFloat = 0.5
    let dotInterval: TimeInterval = 0.5
    var dotAmount: Int = 3
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        damage = 1
        spread = 6
        attackSpeed = 0.015
        bulletLifeTime = 0.6
        bulletSpeed = 0.8
        self.name = "Fire Tower"
        self.dmgType = .fire
        self.type = .fire
        addTurret(_texture: SKTexture(imageNamed: "fireTowerTurret"))
    }
    
    func applyDot(enemy: Enemies) {
        let colourChange = SKAction.colorize(with: UIColor.init(displayP3Red: 1, green: 0.1, blue: 0.1, alpha: 1), colorBlendFactor: 0.4, duration: 0)
        let dot = SKAction.run {
            let didKil = enemy.hit(dmg: self.dotDmg, dmgType: self.dmgType)
            if didKil { self.kills += 1}
        }
        let dotTime = SKAction.wait(forDuration: dotInterval)
        let dotSequence = SKAction.repeat(SKAction.sequence([dotTime,dot]), count: dotAmount)
        let colourBack = SKAction.colorize(withColorBlendFactor: 0, duration: 0)
        let effect = SKAction.sequence([colourChange,dotSequence, colourBack])
        enemy.run(effect)
        
    }
    
    
}

//MARK: ElectricTower

class ElectricTower: Tower {
    
    let electricTextures: [SKTexture] = [SKTexture(imageNamed: "electricEffectOne"), SKTexture(imageNamed: "electricEffectTwo"), SKTexture(imageNamed: "electricEffectThree")]
    var updateCount: Int = 0
    var textureCount: Int = 0
    var effect: SKSpriteNode?
    
    var closestNode: [SKNode]?
    var arcLife: TimeInterval = 0.2
    var arcLifeCount: TimeInterval = 0
    var chains: Int = 1
    
    required init?(coder aDecoder: NSCoder) {
        effect = SKSpriteNode(texture: electricTextures[0])
        super.init(coder: aDecoder)
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        effect = SKSpriteNode(texture: electricTextures[0])
        super.init(texture: texture, color: color, size: size)
        self.attackSpeed = 0.5
        self.name = "electric Tower"
        self.type = .laser
        self.dmgType = .electric
        effect?.zPosition = 1
        effect?.position.y += -3
        self.addChild(effect!)
        //this tower does not have turret

    }
    
    override func shoot() {
        let path = CGMutablePath()
        path.move(to: self.position)
        for i in 0..<chains {
            let newNode = closestNode![i]
            path.addLine(to: closestNode![i].position)
            if (closestNode![i] as? Enemies)?.hit(dmg: damage/CGFloat(i+1), dmgType: dmgType) ?? false {
                kills += 1
            }
            let tooAdd = (self.parent as? GameScene)?.nearestNode(node: newNode)
            if tooAdd?.node != nil && tooAdd?.dist ?? 0 < range/CGFloat(i+1) {
                closestNode?.append(tooAdd!.node!)
            } else { break }
        }
        let arc: SKShapeNode = SKShapeNode(path: path)
        arc.strokeColor = SKColor.blue
        arc.lineWidth = 3
        arc.name = "arc"
        self.parent?.addChild(arc)
        let life =  SKAction.wait(forDuration: arcLife)
        let death = SKAction.removeFromParent()
        let lifeNDeath = SKAction.sequence([life,death])
        arc.run(lifeNDeath)
    }
    
    override func update(closest: SKNode, dist: CGFloat, deltaTime: TimeInterval) {
        closestNode = [closest]
        super.update(closest: closest, dist: dist, deltaTime: deltaTime)
        if updateCount >= 30 {
            textureCount += 1
            effect?.texture = electricTextures[textureCount%3]
            updateCount = 0
        }
        updateCount += 1
        
    }
}

//MARK: Ice tower

class IceTower: Tower {
    
    var slowAmount: CGFloat = 0.6
    var slowDuration: TimeInterval = 2
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.damage = 1
        self.name = "Ice Tower"
        self.dmgType = .ice
        self.type = .ice
        addTurret(_texture: SKTexture(imageNamed: "iceTowerTurret"))
    }
    
    func applySlow(enemy: Enemies) {
        let iceColour = SKAction.colorize(with: #colorLiteral(red: 0.6980392157, green: 0.8431372549, blue: 1, alpha: 1), colorBlendFactor: 0.4, duration: 0)
        let slow = SKAction.speed(to: slowAmount, duration: slowDuration)
        let normalColour = SKAction.colorize(withColorBlendFactor: 0, duration: 0)
        let normalSpeed = SKAction.speed(to: 1, duration: 0)
        
        enemy.run(SKAction.sequence([iceColour,slow,normalColour,normalSpeed]))
        
    }
}
