//
//  File.swift
//  TD School Project
//
//  Created by Jack Darlison on 30/10/2019.
//  Copyright © 2019 Jack Darlison. All rights reserved.
//

import Foundation
import SpriteKit

class GameBar:SKSpriteNode {
    
    var parentNode: Tower
    
    var damage: SKLabelNode
    var attackSpeed: SKLabelNode
    var range: SKLabelNode
    var special: SKLabelNode
    var rangeIndicator: SKShapeNode?
    
    init(texture: SKTexture?, color: UIColor, size: CGSize, _parentNode: Tower) {
        self.parentNode = _parentNode
        self.special = SKLabelNode(fontNamed: "Helvetica")
        self.range = SKLabelNode(fontNamed: "Helvetica")
        self.attackSpeed = SKLabelNode(fontNamed: "Helvetica")
        self.damage = SKLabelNode(fontNamed: "Helvetica")
        self.rangeIndicator = SKShapeNode(circleOfRadius: parentNode.range)
        super.init(texture: texture, color: color, size: size)
        self.position = CGPoint(x: 675, y: 0)
        self.zPosition = 10
        rangeIndicator!.position = self.parentNode.position
        rangeIndicator!.strokeColor = .blue
        rangeIndicator!.lineWidth = 2
        self.parentNode.parent?.addChild(rangeIndicator!)
        createLabels()
        createButtons()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("no coder")
    }
    func createButtons() {
        
        let dmgButton: Button = Button(texture:nil, color: UIColor(displayP3Red: 0.1, green: 1, blue: 0.1, alpha: 1),
                                 size: CGSize(width: 100, height: 100))
        self.addChild(dmgButton)
        dmgButton.position = CGPoint(x: -65, y: 65)
        dmgButton.buttonAction = {
            print("dmg up")
            self.parentNode.damage += 1
            self.damage.text = "damage: \(self.parentNode.damage)"
        }
        let dmgUpTxt:SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        dmgUpTxt.fontSize = 24
        dmgUpTxt.fontColor = SKColor.black
        dmgUpTxt.text = "damage"
        dmgButton.addChild(dmgUpTxt)
    
        let attackSpeedButton: Button = Button(texture:nil, color: UIColor(displayP3Red: 0.1, green: 1, blue: 0.1, alpha: 1),
                                 size: CGSize(width: 100, height: 100))
        self.addChild(attackSpeedButton)
        attackSpeedButton.position = CGPoint(x: 65, y: 65)
        attackSpeedButton.buttonAction = {
            print("attack speed up")
            self.parentNode.attackSpeed += -0.1
            self.attackSpeed.text = "speed: \(self.parentNode.attackSpeed)"
        }
        let attackSpeedUpTxt:SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        attackSpeedUpTxt.fontSize = 24
        attackSpeedUpTxt.fontColor = SKColor.black
        attackSpeedUpTxt.text = "speed"
        attackSpeedButton.addChild(attackSpeedUpTxt)
        
        let rangeButton: Button = Button(texture:nil, color: UIColor(displayP3Red: 0.1, green: 1, blue: 0.1, alpha: 1),
                                 size: CGSize(width: 100, height: 100))
        self.addChild(rangeButton)
        rangeButton.position = CGPoint(x: -65, y: -65)
        rangeButton.buttonAction = {
            print("range up")
            self.parentNode.range += 50
            self.range.text = "range: \(self.parentNode.range)"
            self.rangeIndicator!.removeFromParent()
            self.rangeIndicator = SKShapeNode(circleOfRadius: self.parentNode.range)
            self.rangeIndicator!.position = self.parentNode.position
            self.rangeIndicator!.strokeColor = .blue
            self.rangeIndicator!.lineWidth = 2
            self.parent?.addChild(self.rangeIndicator!)
        }
        let rangeUpTxt:SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        rangeUpTxt.fontSize = 24
        rangeUpTxt.fontColor = SKColor.black
        rangeUpTxt.text = "range"
        rangeButton.addChild(rangeUpTxt)
        
        let specialButton: Button = Button(texture:nil, color: UIColor(displayP3Red: 0.1, green: 1, blue: 0.1, alpha: 1),
                                 size: CGSize(width: 100, height: 100))
        self.addChild(specialButton)
        specialButton.position = CGPoint(x: 65, y: -65)
        specialButton.buttonAction = {
            self.parentNode.specialValue += 1
            if self.parentNode is ElectricTower {
                (self.parentNode as! ElectricTower).chains += 1
            } else if self.parentNode is FireTower {
                (self.parentNode as! FireTower).dotAmount += 1
            } else if self.parentNode is IceTower {
                (self.parentNode as! IceTower).slowDuration += 0.5
                (self.parentNode as! IceTower).slowAmount -= 0.05
            }
            self.special.text = "special: \(self.parentNode.specialValue)"
        }
        let specialUpTxt:SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        specialUpTxt.fontSize = 24
        specialUpTxt.fontColor = SKColor.black
        specialUpTxt.text = "special"
        specialButton.addChild(specialUpTxt)
        
        let sellButton: Button = Button(texture: nil, color: UIColor(displayP3Red: 0.1, green: 1, blue: 0.1, alpha: 1),
                                        size: CGSize(width: 100, height: 100))
        self.addChild(sellButton)
        sellButton.position = CGPoint(x: 0 , y:  -(self.size.height/2) + 75)
        sellButton.buttonAction = {
            (self.parent as? GameScene)?.money += self.parentNode.type.cost
            self.parentNode.removeFromParent()
            self.removeFromParent()
            self.rangeIndicator?.removeFromParent()
        }
        let sellTxt:SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        sellTxt.fontSize = 24
        sellTxt.fontColor = SKColor.black
        sellTxt.text = "sell"
        sellButton.addChild(sellTxt)
        
    }
    func createLabels() {
        let name: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        self.addChild(name)
        name.fontSize = 35
        name.fontColor = SKColor.black
        name.position = CGPoint(x: -115, y: 350)
        name.horizontalAlignmentMode = .left
        name.text = "\(parentNode.name ?? "name not found")"
        
        let kills: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        self.addChild(kills)
        kills.fontSize = 35
        kills.fontColor = SKColor.black
        kills.position = CGPoint(x: -115, y: 300)
        kills.horizontalAlignmentMode = .left
        kills.text = "kills: \(parentNode.kills)"
        
        self.addChild(damage)
        damage.fontSize = 24
        damage.fontColor = SKColor.black
        damage.position = CGPoint(x: -115, y: -200)
        damage.horizontalAlignmentMode = .left
        damage.text = "damage: \(parentNode.damage)"
        
        self.addChild(attackSpeed)
        attackSpeed.fontSize = 24
        attackSpeed.fontColor = SKColor.black
        attackSpeed.position = CGPoint(x: -115, y: -230)
        attackSpeed.horizontalAlignmentMode = .left
        attackSpeed.text = "speed: \(parentNode.attackSpeed)"
        
        self.addChild(range)
        range.fontSize = 24
        range.fontColor = SKColor.black
        range.position = CGPoint(x: -115, y: -260)
        range.horizontalAlignmentMode = .left
        range.text = "range: \(parentNode.range)"
        
        self.addChild(special)
        special.fontSize = 24
        special.fontColor = SKColor.black
        special.position = CGPoint(x: -115, y: -290)
        special.horizontalAlignmentMode = .left
        special.text = "special: \(self.parentNode.specialValue)"
        
    }
}
