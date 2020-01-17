//
//  Enemies.swift
//  TD School Project
//
//  Created by Jack Darlison on 29/09/2019.
//  Copyright © 2019 Jack Darlison. All rights reserved.
//

import Foundation
import SpriteKit

class Enemies: SKSpriteNode {
    
    var health: CGFloat = 20
    var currentHealth: CGFloat
    var armour: CGFloat = 0.5 //coeffecient of damage: lower is better
    var moveSpeed: CGFloat = 150
    var armourType: [damageTypes] = []
    var score: Int = 10
    var money: Int = 10
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init(texture: SKTexture?, color: UIColor, size: CGSize, _path: [(Int, Int)]?, _types: [damageTypes], _dif: Difficulty, _map: Int) {
        health = health*_dif.getHealthMult
        currentHealth = health
        super.init(texture: texture, color: color, size: size)
        score = Int(CGFloat(score)*_dif.getHealthMult)
        moveSpeed = moveSpeed*_dif.getSpeedMult
        armourType.append(contentsOf: _types)
        if armourType.first != damageTypes.none {
            self.money = self.money * armourType.count
            self.score = self.score * armourType.count
            self.run(SKAction.colorize(with: (armourType.first?.color)!, colorBlendFactor: 0.5, duration: 0))
        }
        self.size = size
        self.color = color
        self.name = "enemy"
        self.position = CGPoint(x:-800, y:400)
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.categoryBitMask = bodyTypes.enemy.rawValue
        self.physicsBody?.collisionBitMask = bodyTypes.bullet.rawValue
        self.physicsBody?.contactTestBitMask = bodyTypes.bullet.rawValue
        self.physicsBody?.isDynamic = false

        createHealthBar()
        
        let path = createPath(path: _path, map: _map)
        let move = SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, speed: moveSpeed)
        self.run(move)

    }
    
    func createPath(path: [(Int, Int)]?, map: Int) -> UIBezierPath {
        let route = UIBezierPath()
        
        //  x * 50 - 1/2 width? +25 (centre tile)
        // 1600x900
        
        if map == 0 {
            let tileSize = gameVariables.tileSize.rawValue
            let centreOfTile = tileSize/2
            let halfWidth = gameVariables.width.rawValue/2
            let halfHeight = gameVariables.height.rawValue/2
            
            route.move(to: CGPoint(x: (CGFloat(path![0].1) * tileSize)-halfWidth+centreOfTile, y: (CGFloat(path![0].0) * tileSize)-halfHeight+centreOfTile) )
            let end = path!.count
            for i in 1..<end {
                route.addLine(to: CGPoint(x: (CGFloat(path![i].1) * tileSize)-halfWidth+centreOfTile, y: (CGFloat(path![i].0) * tileSize)-halfHeight+centreOfTile))
            }
            route.addLine(to: CGPoint(x: (CGFloat(path![end-1].1) * tileSize)-halfWidth+centreOfTile+50, y: (CGFloat(path![end-1].0) * tileSize)-halfHeight+centreOfTile))
        } else if map == 1 {
            route.move(to: CGPoint(x: -775, y: 225))
            route.addLine(to: CGPoint(x: -125, y: 225))
            route.addLine(to: CGPoint(x: -125, y: -225))
            route.addLine(to: CGPoint(x: 595, y: -225))
        } else if map == 2 {
            route.move(to: CGPoint(x: -775, y: 135))
            route.addLine(to: CGPoint(x: -485, y: 135))
            route.addLine(to: CGPoint(x: -485, y: 315))
            route.addLine(to: CGPoint(x: -125, y: 315))
            route.addLine(to: CGPoint(x: -125, y: -315))
            route.addLine(to: CGPoint(x: 235, y: -315))
            route.addLine(to: CGPoint(x: 235, y: -135))
            route.addLine(to: CGPoint(x: 595, y: -135))
        } else if map == 3 {
            route.move(to: CGPoint(x: -775, y: 135))
            route.addLine(to: CGPoint(x: -665, y: 135))
            let rand = Int.random(in: 1...2)
            if rand == 1 {
                route.addLine(to: CGPoint(x: -665, y: 315))
                route.addLine(to: CGPoint(x: -305, y: 315))
            } else {
                route.addLine(to: CGPoint(x: -665, y: -45))
                route.addLine(to: CGPoint(x: -305, y: -45))
            }
            route.addLine(to: CGPoint(x: -305, y: 135))
            route.addLine(to: CGPoint(x: -125, y: 135))
            route.addLine(to: CGPoint(x: -125, y: -135))
            route.addLine(to: CGPoint(x: 55, y: -135))
            let rand2 = Int.random(in: 1...2)
            if rand2 == 1 {
                route.addLine(to: CGPoint(x: 55, y: 45))
                route.addLine(to: CGPoint(x: 415, y: 45))
            } else {
                route.addLine(to: CGPoint(x: 55, y: -315))
                route.addLine(to: CGPoint(x: 415, y: -315))
            }
            route.addLine(to: CGPoint(x: 415, y: -135))
            route.addLine(to: CGPoint(x: 595, y: -135))
        }

        return route
    }
    
    func createHealthBar() {
        let red:SKSpriteNode = SKSpriteNode(color: UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 1),
                                            size: CGSize(width: gameVariables.tileSize.rawValue-10, height: (gameVariables.tileSize.rawValue-10)/10))
        let green:SKSpriteNode = SKSpriteNode(color: UIColor(displayP3Red: 0, green: 1, blue: 0, alpha: 1),
                                              size: CGSize(width: gameVariables.tileSize.rawValue-10, height: (gameVariables.tileSize.rawValue-10)/10))
        self.addChild(red)
        self.addChild(green)
        red.name = "red"
        green.name = "green"
        red.anchorPoint = CGPoint(x:0, y:0)
        green.anchorPoint = CGPoint(x:0, y:0)
        red.position = CGPoint(x: -self.size.width/2 + 5, y: self.size.height/2 + (gameVariables.tileSize.rawValue-10)/10)
        green.position = CGPoint(x: -self.size.width/2 + 5, y: self.size.height/2 + (gameVariables.tileSize.rawValue-10)/10)

    }
    
    func hit(dmg: CGFloat, dmgType: damageTypes) -> Bool {
        var damage = dmg
        if armourType.contains(dmgType) {
            damage = damage * armour
        }
        currentHealth = currentHealth-damage
        if (currentHealth) <= 0 {
            (self.parent as? GameScene)?.score += self.score
            (self.parent as? GameScene)?.money += self.money
            self.removeFromParent()
            return true
        } else {
            let healthPerc:CGFloat = (CGFloat(currentHealth/health))
            (self.childNode(withName: "green") as? SKSpriteNode)?.size.width = healthPerc * (gameVariables.tileSize.rawValue-10)
        }
        return false
    }
}
