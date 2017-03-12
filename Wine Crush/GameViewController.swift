//
//  StartViewController.swift
//  Wine Crush
//
//  Created by Joey deVilla on 2016-02-12.
//  Copyright © 2016 Joey deVilla. All rights reserved.
//  MIT License. See the end of the file for the gory details.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
  
  var switchingViewController: SwitchingViewController!
  
  @IBOutlet weak var levelLabel: UILabel!
  @IBOutlet weak var movesLabel: UILabel!
  @IBOutlet weak var pointsToGoLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var noticePanel: UIImageView!
  @IBOutlet weak var shuffleButton: UIButton!
  @IBOutlet weak var hintButton: UIButton!
  @IBOutlet weak var quitButton: UIButton!
  @IBOutlet weak var noticeView: UIView!
  @IBOutlet weak var noticeTitleLabel: UILabel!
  @IBOutlet weak var noticeMessageLabel: UILabel!
  
  let maximumLevelDefined = 29
  let maximumBackgroundDefined = 4
  
  // The scene draws the tiles and cookie sprites, and handles swipes.
  var scene: GameScene!

  // The level contains the tiles, the cookies, and most of the gameplay logic.
  // Needs to be ! because it's not set in init() but in viewDidLoad().
  var level: Level!
  var levelNumber = 1

  var movesLeft = 0
  var gameScore = 0
  var levelScore = 0
  var targetScore = 0

  var hintGiven = false


  var tapGestureRecognizer: UITapGestureRecognizer!

  lazy var backgroundMusic: AVAudioPlayer! = {
    let url = Bundle.main.url(forResource: "Mining by Moonlight", withExtension: "mp3")
    do {
      let player = try AVAudioPlayer(contentsOf: url!)
      player.numberOfLoops = -1
      return player
      
    }
    catch {
      fatalError("Error loading \(url): \(error)")
    }
  }()

  override var prefersStatusBarHidden : Bool {
    return true
  }

  override var shouldAutorotate : Bool {
    return true
  }

  override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.allButUpsideDown
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Configure the view.
    let skView = view as! SKView
    skView.isMultipleTouchEnabled = false
    
    // Create and configure the scene.
    scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .aspectFill
    
    // Present the scene.
    skView.presentScene(scene)
//    beginGame()
  }
  
  func beginGame() {
    // Hide the end of play panel from the screen.
//    noticePanel.hidden = true
    hideNoticeView()
    
    shuffleButton.isEnabled = false
    hintButton.isEnabled = false
    
    // Load and start background music.
    backgroundMusic.currentTime = 0.0
    backgroundMusic.volume = 1.0
    backgroundMusic.play()
    
    // Let's start the game!
    gameScore = 0
    levelNumber = 1
    beginLevel()
  }

  func beginLevel() {
    
    scene.run(SKAction.wait(forDuration: 2.0))
    
    // Load the level.
    levelScore = 0
    
    let levelToLoad = ((levelNumber - 1) % maximumLevelDefined) + 1
    level = Level(filename: "Level_\(levelToLoad)")
    print("Loaded level \(levelNumber)")
    level.resetComboMultiplier()
    
    // The game gets tougher as you complete a cycle of levels.
    // With each new cycle, you get:
    // - One less move
    // - 60 points added to the target score
    let cycle = (levelNumber - 1) / maximumLevelDefined
    movesLeft = level.maximumMoves - cycle
    targetScore = level.targetScore + 60 * cycle
    
    updateLabels()
    
    let backgroundToLoad = ((levelNumber - 1) % maximumBackgroundDefined) + 1
    scene.background.texture = SKTexture(imageNamed: "Background_\(backgroundToLoad)")
    
    scene.tilesLayer.removeAllChildren()
    scene.level = level
    
    hintGiven = false
    
    delay(4.0) {
      self.scene.addTiles()
      self.scene.swipeHandler = self.handleSwipe
      self.scene.animateBeginLevel() {
        self.shuffleButton.isEnabled = true
        self.hintButton.isEnabled = true
        self.quitButton.isEnabled = true
        self.view.isUserInteractionEnabled = true
      }
      self.shuffle()
    }
  }

  func shuffle() {
    // Delete the old cookie sprites, but not the tiles.
    scene.removeAllCookieSprites()

    // Fill up the level with new cookies, and create sprites for them.
    let newCookies = level.shuffle()
    scene.addSpritesForCookies(newCookies)
    scene.update(0)
  }

  // This is the swipe handler. MyScene invokes this function whenever it
  // detects that the player performs a swipe.
  func handleSwipe(_ swap: Swap) {
    // While cookies are being matched and new cookies fall down to fill up
    // the holes, we don't want the player to tap on anything.
    view.isUserInteractionEnabled = false

    if level.isPossibleSwap(swap) {
      level.performSwap(swap)
      scene.animateSwap(swap, completion: handleMatches)
    } else {
      scene.animateInvalidSwap(swap) {
        self.view.isUserInteractionEnabled = true
      }
    }
  }

  // This is the main loop that removes any matching cookies and fills up the
  // holes with new cookies. While this happens, the user cannot interact with
  // the app.
  func handleMatches() {
    // Detect if there are any matches left.
    let chains = level.removeMatches()

    // If there are no more matches, then the player gets to move again.
    if chains.count == 0 {
      beginNextTurn()
      return
    }

    // First, remove any matches...
    scene.animateMatchedCookies(chains) {

      // Add the new scores to the total.
      for chain in chains {
        self.gameScore += chain.score
        self.levelScore += chain.score
      }
      self.updateLabels()

      // ...then shift down any cookies that have a hole below them...
      let columns = self.level.fillHoles()
      self.scene.animateFallingCookies(columns) {

        // ...and finally, add new cookies at the top.
        let columns = self.level.topUpCookies()
        self.scene.animateNewCookies(columns) {

          // Keep repeating this cycle until there are no more matches.
          self.handleMatches()
        }
      }
    }
  }

  func beginNextTurn() {
    level.resetComboMultiplier()
    level.detectPossibleSwaps()
    hintGiven = false
    view.isUserInteractionEnabled = true
    decrementMoves()
  }

  func updateLabels() {
    levelLabel.text = String(format: "%ld", levelNumber)
    movesLabel.text = String(format: "%ld", movesLeft)
    
    let pointsToGo: Int
    if levelScore < targetScore {
      pointsToGo = targetScore - levelScore
    }
    else {
      pointsToGo = 0
    }
    pointsToGoLabel.text = String(format: "%ld", pointsToGo)
    
    scoreLabel.text = String(format: "%ld", gameScore)
    
  }

  func decrementMoves() {
    movesLeft -= 1
    updateLabels()

    if levelScore >= targetScore {
//      noticePanel.image = UIImage(named: "LevelComplete")
      showEndOfPlay(gameOver: false)
    } else if movesLeft == 0 {
//      noticePanel.image = UIImage(named: "GameOver")
      showEndOfPlay(gameOver: true)
    } else if level.swapsCount() == 0 {
//      noticePanel.image = UIImage(named: "NoPossibleSwaps")
      showNoPossibleSwaps()
    }
  }

  func showEndOfPlay(gameOver: Bool = false) {
//    noticePanel.hidden = false
    let theTitle: String
    let theMessage: String
    if gameOver {
      theTitle = "Game Over"
      theMessage = "Now go enjoy some wine!"
    }
    else {
      theTitle = "Level Complete"
      theMessage = "Get ready for the next one..."
    }
    showNoticeView(title: theTitle, message: theMessage)
    view.isUserInteractionEnabled = false
    shuffleButton.isEnabled = false
    hintButton.isEnabled = false
    quitButton.isEnabled = false
    
    scene.tilesLayer.removeAllChildren()
    scene.removeAllCookieSprites()
    
    if gameOver {
      self.quitButton.isEnabled = false
      self.fadeOutBackgroundMusic()
    }
    
    delay(4.0) {
      if gameOver {
        self.endGame()
      }
      else {
        self.increaseLevel()
      }
    }
  }
  
  func fadeOutBackgroundMusic() {
    if backgroundMusic.volume > 0.1 {
      backgroundMusic.volume -= 0.1
      perform(#selector(fadeOutBackgroundMusic), with: nil, afterDelay: 0.1)
    }
    else {
      backgroundMusic.stop()
    }
  }
  
  func showNoPossibleSwaps() {
//    noticePanel.hidden = false
    showNoticeView(title: "No Possible Swaps!", message: "Use the Shuffle button.")
    scene.isUserInteractionEnabled = false
    shuffleButton.isEnabled = false
    hintButton.isEnabled = false
    
    delay(3.0) {
//      self.noticePanel.hidden = true
      self.hideNoticeView()
      self.scene.isUserInteractionEnabled = true
      self.shuffleButton.isEnabled = true
    }
  }
  
  func increaseLevel() {
//    noticePanel.hidden = true
    hideNoticeView()
    scene.isUserInteractionEnabled = true
    
    levelNumber += 1
    beginLevel()
  }

  func endGame() {
    switchingViewController.switchViews()
  }
  


  @IBAction func shuffleButtonPressed(_: AnyObject) {
    shuffle()
    hintGiven = false
    hintButton.isEnabled = true

    // Pressing the shuffle button costs a move.
    decrementMoves()
  }
  
  @IBAction func hintButtonPressed(_: AnyObject) {
    if let swap = level.hint() {
      view.isUserInteractionEnabled = false
      scene.animateInvalidSwap(swap) {
        self.view.isUserInteractionEnabled = true
        if !self.hintGiven {
          self.gameScore = max(self.gameScore - 10, 0)
          self.levelScore = max(self.levelScore - 10, 0)
          self.hintGiven = true
        }
        self.updateLabels()
      }
    }
    else {
      print("No moves")
    }
  }
  
  @IBAction func quitButtonPressed(_: AnyObject) {
//    increaseLevel()
    let alertController = UIAlertController(
      title: "Quit the game?",
      message: "Are you sure you want to quit playing?",
      preferredStyle: .alert)
    let quitAction = UIAlertAction(
      title: "Yes, I'm done playing.",
      style: .destructive) { (action: UIAlertAction!) in
        self.shuffleButton.isEnabled = false
        self.hintButton.isEnabled = false
        self.quitButton.isEnabled = false
        self.scene.tilesLayer.removeAllChildren()
        self.scene.removeAllCookieSprites()
        self.fadeOutBackgroundMusic()
        self.endGame()
    }
    let cancelAction = UIAlertAction(
      title: "No, let me keep playing!",
      style: UIAlertActionStyle.default) { action in
        self.view.isUserInteractionEnabled = true
    }
    alertController.addAction(quitAction)
    alertController.addAction(cancelAction)
    present(alertController, animated: true, completion: nil)
  }
  
  func showNoticeView(title: String, message: String) {
    noticeTitleLabel.text = title
    noticeMessageLabel.text = message
    noticeView.isHidden = false
  }
  
  func hideNoticeView() {
    noticeView.isHidden = true
  }
  
}


func delay(_ delay: Double, closure: @escaping ()->()) {
  DispatchQueue.main.asyncAfter(
    deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
    execute: closure
  )
}

// This code is released under the MIT license and contains code from
// RayWenderlich.com, which is released under an equally permissive license.
// Simply put, you're free to use this in your own projects, both
// personal and commercial, as long as you include the copyright notice below.
// It would be nice if you mentioned my name somewhere in your documentation
// or credits.
//
// MIT LICENSE
// -----------
// (As defined in https://opensource.org/licenses/MIT)
//
// Copyright © 2016 Joey deVilla. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom
// the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
// OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
