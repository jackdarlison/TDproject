//
//  GameViewController.swift
//  TD School Project iOS
//
//  Created by Jack Darlison on 02/09/2019.
//  Copyright © 2019 Jack Darlison. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

protocol SceneManager {
    func pauseGame(_which:whichScene)
    func loadGame()
    func newGame()
    func loadMenu()
    
}

class GameViewController: UIViewController, SceneManager {
    
    var gameScene: GameScene?
    var pauseScene: PauseMenu?
    
    func pauseGame(_which: whichScene) {
        
        let skView = self.view as! SKView
        pauseScene = PauseMenu.newPauseScene()
        pauseScene?.which = _which
        pauseScene?.manager = self
        pauseScene?.scaleMode = .aspectFit
        skView.presentScene(pauseScene!)

    }
    
    func newGame() {
        gameScene = GameScene.newGameScene()
        gameScene?.manager = self
    }
    
    
    func loadGame() {
        
        let fadeLength = 0.1
        let fadeColor = UIColor.white
        let transition = SKTransition.fade(with: fadeColor, duration: fadeLength)
        transition.pausesIncomingScene = false
        
        let skView = self.view as! SKView
        skView.presentScene(gameScene!, transition: transition)
    }
    
    func loadMenu() {
        let scene = MainMenu.newMainMenuScene()
        scene.manager = self
        
        let skView = self.view as! SKView
        
        skView.presentScene(scene)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        newGame()
        
        loadMenu()
        
        let skView = self.view as! SKView

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
