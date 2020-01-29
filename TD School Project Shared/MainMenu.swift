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
    let textInput = UITextField(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 200, height: 50)))
    var manager: SceneManager?
    var background:SKSpriteNode?
    var difficulty: Difficulty = .easy {
        didSet {
            (self.childNode(withName: "difficultyButton")?.childNode(withName: "difficultyButtonText") as! SKLabelNode).text = difficulty.getLetter
        }
    }
    var map: Int = 0 {
        didSet {
            switch map {
            case 0:
                (self.childNode(withName: "mapButton")?.childNode(withName: "mapButtonText") as! SKLabelNode).text = "R"
            default:
                (self.childNode(withName: "mapButton")?.childNode(withName: "mapButtonText") as! SKLabelNode).text = "\(map)"
            }
        }
    }
    
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
        self.isUserInteractionEnabled = true
        
        if userInfo.integer(forKey: "highscore") == 0 {
            print("no highscore set for this user")
        } else {
            print(userInfo.integer(forKey: "highscore"))
        }
        
        if userInfo.object(forKey: "name") == nil {
            print("no user")
            makeTextField(defaultText: "Input username")
        } else {
            print(userInfo.object(forKey: "name")!)
        }
        
        
        playButton = self.childNode(withName: "playButton") as? Button
        playButton.buttonAction = {
            print("button clicked")
            self.manager!.newGame(_dif: self.difficulty, _map: self.map)
            self.manager!.loadGame()
        }
        
        let settingButton = self.childNode(withName: "settingsButton") as? Button
        settingButton?.buttonAction = {
            if self.childNode(withName: "background") == nil {
                self.createSettings()
            }

        }
        
        let difficultyButton = self.childNode(withName: "difficultyButton") as? Button
        difficultyButton?.buttonAction = {
            switch self.difficulty {
            case .easy:
                self.difficulty = .medium
            case .medium:
                self.difficulty = .hard
            case .hard:
                self.difficulty = .easy
            }
        }
        
        let mapButton = self.childNode(withName: "mapButton") as? Button
        mapButton?.buttonAction = {
            self.map = (self.map+1)%4
        }
 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        background?.removeFromParent()
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 8
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let isValid = try! NSRegularExpression(pattern: "(\\w|\\s){3,8}")
        let text = textField.text!
        let result = isValid.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count))
        if result != nil {
            let textRange = Range(result!.range, in: text)
            let newText = text[textRange!]
            textField.resignFirstResponder()
            self.user = String(newText)
            self.userInfo.set(user, forKey: "name")
            textField.removeFromSuperview()
            (background?.childNode(withName: "name") as! SKLabelNode).text = "Name:" + (userInfo.object(forKey: "name") as? String ?? "no name")
        } else {
            textField.placeholder = "Enter valid: 3 to 8 alphanum"
        }
        return true
    }

    func createSettings() {
        background = SKSpriteNode(color: .lightGray, size: CGSize(width: 1000, height: 500))
        background?.name = "background"
        background?.zPosition = 100
        self.addChild(background!)
        let nameLabel = SKLabelNode(fontNamed: "Helvetica")
        nameLabel.text = "Name:" + (userInfo.object(forKey: "name") as? String ?? "no name")
        nameLabel.name = "name"
        let scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        scoreLabel.text = "Score:" + String(userInfo.integer(forKey: "highscore"))
        background?.addChild(nameLabel)
        background?.addChild(scoreLabel)
        nameLabel.position = CGPoint(x: 0, y: 200)
        scoreLabel.position = CGPoint(x: 0, y: 150)
        
        let renameButton = Button(texture: nil, color: .blue, size: CGSize(width: 100, height: 100))
        renameButton.buttonAction = {
            self.makeTextField(defaultText: "New username")
        }
        renameButton.position = CGPoint(x: 0, y: -150)
        let renameLabel = SKLabelNode(fontNamed: "Helvetica")
        renameLabel.text = "R"
        renameLabel.fontSize = 40
        renameButton.addChild(renameLabel)
        background?.addChild(renameButton)
        
    }
    
    func makeTextField(defaultText: String) {
        textInput.backgroundColor = SKColor.white
        textInput.delegate = self
        textInput.placeholder = defaultText
        self.scene?.view?.addSubview(textInput)
        textInput.becomeFirstResponder()
    }
    
}


