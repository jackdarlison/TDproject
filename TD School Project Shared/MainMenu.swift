//
//  MainMenu.swift
//  TD School Project
//
//  Created by Jack Darlison on 12/09/2019.
//  Copyright © 2019 Jack Darlison. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenu: SKScene, UITextFieldDelegate {

    let userInfo = UserDefaults.standard
    var user:String? = nil
    var highscore:Int? = nil
    let textInput = UITextField(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 50)))
    var manager: SceneManager?
    
    //handler for the button
    
    var playButton: Button!
    
    class func newMainMenuScene() -> MainMenu {
        // Load 'MainMenu.sks' as an SKScene.
        guard let scene = MainMenu(fileNamed: "MainMenu") else {
            print("Failed to load MainMenu.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    // runs when the scene is loaded. sets up button to run the loadseen function.
    
    override func didMove(to view: SKView) {
        
        textInput.backgroundColor = SKColor.white
        textInput.delegate = self
        textInput.placeholder = "input username"
        
        
        if userInfo.integer(forKey: "highscore") == 0 {
            print("no highscore set for this user")
            userInfo.set(400, forKey: "highscore")
        } else {
            print(userInfo.integer(forKey: "highscore"))
        }
        
        if userInfo.object(forKey: "name") == nil {
            print("no user")
            self.scene?.view?.addSubview(textInput)
            textInput.becomeFirstResponder()
        } else {
            print(userInfo.object(forKey: "name")!)
        }
        
        
        playButton = self.childNode(withName: "playButton") as? Button
        playButton.buttonAction = {
            print("button clicked")
            self.manager!.newGame()
            self.manager!.loadGame()
        }
 
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.user = textField.text
        self.userInfo.set(user, forKey: "name")
        textField.removeFromSuperview()
        return true
    }
    
    // function is run when needing to change scenes this currently runs the game scene,
    // it first grabs a handler for the view then makes that chnage the the new scene.
    
}


