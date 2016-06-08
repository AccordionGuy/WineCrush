//
//  StartViewController.swift
//  Wine Crush
//
//  Created by Joey deVilla on 2016-02-12.
//  Copyright © 2016 Joey deVilla. All rights reserved.
//  MIT License. See the end of the file for the gory details.
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
