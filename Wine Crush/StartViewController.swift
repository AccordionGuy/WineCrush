//
//  StartViewController.swift
//  CookieCrunch
//
//  Created by Jose Martin DeVilla on 2/20/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

enum WebPageType: Int, CustomStringConvertible {
  case AboutGame = 0
  case AboutAspirations
  
  var fileName: String {
    let fileNames = [
      "about_game",
      "about_aspirations"
    ]
    return fileNames[rawValue]
  }
  
  var description: String {
    return fileName
  }
}

class StartViewController: UIViewController {
  
  var switchingViewController: SwitchingViewController!

  @IBOutlet weak var aboutGameButton: UIButton!
  @IBOutlet weak var aboutAspirationsButton: UIButton!
  
  var selectedPage: WebPageType!

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func playGameButtonPressed(sender: UIButton) {
    switchingViewController.switchViews()
  }
  
  @IBAction func aboutButtonPressed(sender: UIButton) {
    if sender == aboutGameButton {
      selectedPage = .AboutGame
    }
    else {
      selectedPage = .AboutAspirations
    }
    performSegueWithIdentifier("AboutSegue", sender: self)
  }
  
  @IBAction func visitWebsiteButtonPressed(sender: UIButton) {
    UIApplication.sharedApplication().openURL(NSURL(string: "http://www.aspirationswinery.com/")!)
  }
  
  @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
  }
    
  

//  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    if segue.identifier == "AboutSegue" {
//      let aboutViewController = segue.destinationViewController as! AboutViewController
//      aboutViewController.webPage = selectedPage
//    }
//  }

}
