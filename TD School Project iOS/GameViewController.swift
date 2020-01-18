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
    func newGame(_dif:Difficulty, _map: Int)
    func loadMenu()
    func retryGame()
    
}

class GameViewController: UIViewController, SceneManager {
    
    var gameScene: GameScene?
    var pauseScene: PauseMenu?
    let userInfo = UserDefaults.standard
    
    func pauseGame(_which: whichScene) {
        
        let skView = self.view as! SKView
        pauseScene = PauseMenu.newPauseScene()
        pauseScene?.which = _which
        pauseScene?.manager = self
        pauseScene?.scaleMode = .aspectFit
        skView.presentScene(pauseScene!)

    }
    
    func newGame(_dif: Difficulty, _map: Int) {
        gameScene = GameScene.newGameScene()
        gameScene?.difficulty = _dif
        gameScene?.whichMap = _map
        gameScene?.manager = self
    }
    
    func retryGame() {
        let oldGame: GameScene = gameScene!
        gameScene = GameScene.newGameScene()
        gameScene?.path = oldGame.path
        gameScene?.map = oldGame.map
        gameScene?.whichMap = oldGame.whichMap
        gameScene?.difficulty = oldGame.difficulty
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
        
        for i in 0...9 {
            if userInfo.object(forKey: "map\(i)") == nil {
                userInfo.set("not completed", forKey: "map\(i)")
            }
        }
        
        super.viewDidLoad()
        
        newGame(_dif: .easy, _map: 0)
        
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
