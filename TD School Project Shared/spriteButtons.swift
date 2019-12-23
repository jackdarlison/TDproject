//
//  spriteButton.swift
//  TD School Project
//
//  Created by Jack Darlison on 12/09/2019.
//  Copyright © 2019 Jack Darlison. All rights reserved.
//

import Foundation
import SpriteKit


enum buttonState {
    case active, selected, hidden
}

class Button: SKSpriteNode {
    
    var buttonAction: () -> Void = { print("No button action set") }
    
    var state: buttonState = .active {
        didSet {
            switch state {
                
            case .active:
                self.isUserInteractionEnabled = true
                self.alpha = 1
                break
                
            case .selected:
                self.alpha = 0.7
                break
                
            case .hidden:
                self.isUserInteractionEnabled = false
                self.alpha = 0
                break
            
            }
        }
    }
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
    }
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .selected
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonAction()
        state = .active
    }
    #endif
}

class TowerButton: Button {
    
    var currentTower:Tower?
    var whichTower:towerTypes?
    var spawningTower: Bool?
    let tileSize = gameVariables.tileSize.rawValue
    let halfTile = gameVariables.tileSize.rawValue/2
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
    }
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .selected
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self.parent!)
        if (self.parent as? GameScene)?.money ?? 0 >= whichTower!.cost {
            spawningTower = true
            currentTower = spawnTower()
            (self.parent as? GameScene)?.money += -whichTower!.cost
        } else {
            spawningTower = false
        }
        currentTower?.actualPos = touchLocation
        currentTower?.position = CGPoint(x: CGFloat(Int((currentTower?.actualPos?.x)!)/Int(tileSize))*tileSize + halfTile,
                                         y: CGFloat(Int((currentTower?.actualPos?.y)!)/Int(tileSize))*tileSize + halfTile)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .selected
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self.parent!)
        
        currentTower?.actualPos = touchLocation
        let gridCorrection = tileSize - CGFloat(Int(gameVariables.width.rawValue/2)%Int(tileSize))
        
        let xCorrection:CGFloat?
        if (currentTower?.actualPos?.x ?? 0) > CGFloat(0) {
            xCorrection = halfTile + gridCorrection
        } else {
            xCorrection = -halfTile + gridCorrection
        }
        let yCorrection:CGFloat?
        if (currentTower?.actualPos?.y ?? 0) > CGFloat(0) {
            yCorrection = halfTile
        } else {
            yCorrection = -halfTile
        }
        currentTower?.position = CGPoint(x: CGFloat(Int((currentTower?.actualPos?.x)!)/Int(tileSize))*tileSize + xCorrection!,
                                         y: CGFloat(Int((currentTower?.actualPos?.y)!)/Int(tileSize))*tileSize + yCorrection!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .active
        guard let touch = touches.first else {
            return
        }

        let map = (self.parent as? GameScene)?.map
        let touchLocation = touch.location(in: map!)
        let x = map?.tileColumnIndex(fromPosition: touchLocation)
        let y = map?.tileRowIndex(fromPosition: touchLocation)
        let tile = map?.tileDefinition(atColumn: x!, row: y!)
        var canPlace = tile?.userData?["canPlace"] as? Bool
        for child in (parent?.children)! {
            if child is Tower && child.position == currentTower?.position && child != currentTower {
                canPlace = false
                break
            }
        }
        if canPlace == true {
            print("placed")
            currentTower?.placed = true
        } else {
            print("invalid placemnet")
            if spawningTower == true {
                (self.parent as? GameScene)?.money += whichTower!.cost
            }
            currentTower?.removeFromParent()
        }
        currentTower = nil
    }
    #endif
    
    func spawnTower() -> Tower? {
        let temp: Tower = whichTower!.createTower
        self.parent?.addChild(temp)
        return temp
    }
}
