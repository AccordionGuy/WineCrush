//
//  GameViewController.swift
//  CookieCrunch
//
//  Created by Matthijs on 19-06-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
  
//  var switchingViewController: SwitchingViewController!
  
  @IBOutlet weak var levelLabel: UILabel!
  @IBOutlet weak var movesLabel: UILabel!
  @IBOutlet weak var pointsToGoLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var noticePanel: UIImageView!
  @IBOutlet weak var shuffleButton: UIButton!
  @IBOutlet weak var hintButton: UIButton!
  @IBOutlet weak var quitButton: UIButton!
  
  // The scene draws the tiles and cookie sprites, and handles swipes.
  var scene: GameScene!

  // The level contains the tiles, the cookies, and most of the gameplay logic.
  // Needs to be ! because it's not set in init() but in viewDidLoad().
  var level: Level!
  var levelNumber = 1

  var movesLeft = 0
  var gameScore = 999999
  var levelScore = 0



  var tapGestureRecognizer: UITapGestureRecognizer!

  lazy var backgroundMusic: AVAudioPlayer! = {
    let url = NSBundle.mainBundle().URLForResource("Mining by Moonlight", withExtension: "mp3")
    do {
      let player = try AVAudioPlayer(contentsOfURL: url!)
      player.numberOfLoops = -1
      return player
      
    }
    catch {
      fatalError("Error loading \(url): \(error)")
    }
  }()

  override func prefersStatusBarHidden() -> Bool {
    return true
  }

  override func shouldAutorotate() -> Bool {
    return true
  }

  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.AllButUpsideDown
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Configure the view.
    let skView = view as! SKView
    skView.multipleTouchEnabled = false
    
    // Create and configure the scene.
    scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .AspectFill
    
    // Present the scene.
    skView.presentScene(scene)
    beginGame()
  }
  
  func beginGame() {
    // Hide the end of play panel from the screen.
    noticePanel.hidden = true
    
    shuffleButton.enabled = false
    hintButton.enabled = false
    
    // Load and start background music.
    backgroundMusic.play()
    
    // Let's start the game!
    gameScore = 0
    levelNumber = 1
    beginLevel()
  }

  func beginLevel() {
    
    scene.runAction(SKAction.waitForDuration(2.0))
    
    // Load the level.
    levelScore = 0
    
    level = Level(filename: "Level_\(levelNumber)")
    print("Loaded level \(levelNumber)")
    level.resetComboMultiplier()
    movesLeft = level.maximumMoves
    updateLabels()
    
    scene.background.texture = SKTexture(imageNamed: "Background_\((levelNumber - 1) % 4 + 1)")
//    scene.background.setScale(0.70)
    scene.tilesLayer.removeAllChildren()
    scene.level = level
    
    delay(4.0) {
      self.scene.addTiles()
      self.scene.swipeHandler = self.handleSwipe
      self.scene.animateBeginLevel() {
        self.shuffleButton.enabled = true
        self.hintButton.enabled = true
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
  func handleSwipe(swap: Swap) {
    // While cookies are being matched and new cookies fall down to fill up
    // the holes, we don't want the player to tap on anything.
    view.userInteractionEnabled = false

    if level.isPossibleSwap(swap) {
      level.performSwap(swap)
      scene.animateSwap(swap, completion: handleMatches)
    } else {
      scene.animateInvalidSwap(swap) {
        self.view.userInteractionEnabled = true
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
    view.userInteractionEnabled = true
    decrementMoves()
  }

  func updateLabels() {
    levelLabel.text = String(format: "%ld", levelNumber)
    movesLabel.text = String(format: "%ld", movesLeft)
    
    let pointsToGo: Int
    if levelScore < level.targetScore {
      pointsToGo = level.targetScore - levelScore
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

    if levelScore >= level.targetScore {
      noticePanel.image = UIImage(named: "LevelComplete")
      showEndOfPlay(gameOver: false)
    } else if movesLeft == 0 {
      noticePanel.image = UIImage(named: "GameOver")
      showEndOfPlay(gameOver: true)
    } else if level.swapsCount() == 0 {
      noticePanel.image = UIImage(named: "NoPossibleSwaps")
      showNoPossibleSwaps()
    }
  }

  func showEndOfPlay(gameOver gameOver: Bool = false) {
    noticePanel.hidden = false
    scene.userInteractionEnabled = false
    shuffleButton.enabled = false
    hintButton.enabled = false
    
    scene.tilesLayer.removeAllChildren()
    scene.removeAllCookieSprites()
    
    if gameOver {
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
      performSelector("fadeOutBackgroundMusic", withObject: nil, afterDelay: 0.1)
    }
    else {
      backgroundMusic.stop()
    }
  }
  
  func showNoPossibleSwaps() {
    noticePanel.hidden = false
    scene.userInteractionEnabled = false
    shuffleButton.enabled = false
    hintButton.enabled = false
    
    delay(3.0) {
      self.noticePanel.hidden = true
      self.scene.userInteractionEnabled = true
      self.shuffleButton.enabled = true
    }
  }
  
  func increaseLevel() {
    noticePanel.hidden = true
    scene.userInteractionEnabled = true
    
    levelNumber += 1
    if levelNumber > 4 {
      levelNumber = 0
    }
    beginLevel()
  }

  func endGame() {
    noticePanel.hidden = true
//    scene.userInteractionEnabled = false
//    backgroundMusic.stop()

    beginGame()
  }
  


  @IBAction func shuffleButtonPressed(_: AnyObject) {
    shuffle()
    hintButton.enabled = true

    // Pressing the shuffle button costs a move.
    decrementMoves()
  }
  
  @IBAction func hintButtonPressed(_: AnyObject) {
    if let swap = level.hint() {
      view.userInteractionEnabled = false
      scene.animateInvalidSwap(swap) {
        self.view.userInteractionEnabled = true
      }
    }
    else {
      print("No moves")
    }
  }
  
  @IBAction func quitButtonPressed(_: AnyObject) {
    let alertController = UIAlertController(
      title: "Quit the game?",
      message: "Are you sure you want to quit playing?",
      preferredStyle: .Alert)
    let quitAction = UIAlertAction(
      title: "Yes, I'm done playing.",
      style: .Destructive) { (action: UIAlertAction!) in
        self.scene.tilesLayer.removeAllChildren()
        self.scene.removeAllCookieSprites()
        self.endGame()
    }
    let cancelAction = UIAlertAction(
      title: "No, let me keep playing!",
      style: UIAlertActionStyle.Default) { action in
        self.view.userInteractionEnabled = true
    }
    alertController.addAction(quitAction)
    alertController.addAction(cancelAction)
    presentViewController(alertController, animated: true, completion: nil)
  }
  
}


func delay(delay: Double, closure: ()->()) {
  dispatch_after(
    dispatch_time(
      DISPATCH_TIME_NOW,
      Int64(delay * Double(NSEC_PER_SEC))
    ),
    dispatch_get_main_queue(),
    closure
  )
}