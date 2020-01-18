//
//  PauseMenu.swift
//  TD School Project
//
//  Created by Jack Darlison on 29/11/2019.
//  Copyright © 2019 Jack Darlison. All rights reserved.
//

import Foundation
import SpriteKit

enum whichScene {
    
    case pause
    case end
    case win
    
}


class PauseMenu: SKScene {
    
    var which:whichScene = .pause
    var manager:SceneManager?
    
    class func newPauseScene() -> PauseMenu {
        // Load 'pauseScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "PauseMenu") as? PauseMenu else {
            print("Failed to load PauseMenu.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        // scene.scaleMode = .aspectFill
        
        return scene
    }
    
    override func didMove(to view: SKView) {
        
        if let tester:Button = self.childNode(withName: "retry") as? Button {
            print("retry button created")
            let retryButton = tester
            retryButton.buttonAction = {
                self.manager?.retryGame()
                self.manager?.loadGame()
            }
        } else {
            print("retry button not created")
        }
        
        if let tester:Button = self.childNode(withName: "continue") as? Button {
            print("continue button created")
            let continueButton = tester
            continueButton.buttonAction = {self.manager?.loadGame()}
        } else {
            print("continue not created")
        }
        
        if let tester:Button = self.childNode(withName: "mainMenu") as? Button {
            print("main menu button created")
            let menuButton = tester
            menuButton.buttonAction = {self.manager?.loadMenu()}
        } else {
            print("menu button not created")
        }
        
        if let tester:SKLabelNode = self.childNode(withName: "label") as? SKLabelNode {
            print("label created")
            if which == .pause {
                tester.text = "paused!"
            } else if which == .end {
                tester.text = "You died!"
            } else if which == .win {
                tester.text = "You Win!"
            }
        } else {
            print("label not created")
        }
        
        print("moved to pause scene view")
        

    }
    
    
    
    
    
}
