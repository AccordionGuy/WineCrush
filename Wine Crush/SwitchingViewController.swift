//
//  SwitchingViewController.swift
//  Wine Crush
//
//  Created by Joey deVilla on 2016-02-10.
//  Copyright © 2016 Joey deVilla. All rights reserved.
//  MIT License. See the end of the file for the gory details.
//

import UIKit
import AVFoundation

class SwitchingViewController: UIViewController {
  
  fileprivate var startViewController: StartViewController!
  fileprivate var gameViewController: GameViewController!
  

  override func viewDidLoad() {
    super.viewDidLoad()

    gameViewController = storyboard?.instantiateViewController(withIdentifier: "Game")
      as! GameViewController
    gameViewController.switchingViewController = self
    
    startViewController = storyboard?.instantiateViewController(withIdentifier: "Start")
      as! StartViewController
    startViewController.switchingViewController = self
    startViewController.view.frame = view.frame
    switchViewController(from: nil, to: startViewController)
    
    // Setting this app's audio session category to ambient has the results:
    // - Audio from other apps mixes with this app's audio
    // - Audio from this app is silenced when:
    //    - The screen is locked
    //    - The silent switch (ring/silent switch on the iPhone) is set to silent
    try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient,
                                                     with: .mixWithOthers)
  }

//  override func didReceiveMemoryWarning() {
//      super.didReceiveMemoryWarning()
//    
//    if startViewController != nil &&
//       startViewController!.view.superview == nil {
//      startViewController = nil
//    }
//    
//    if gameViewController != nil &&
//       gameViewController!.view.superview == nil {
//      gameViewController = nil
//    }
//    
//  }
  
  func switchViewController(from fromViewController: UIViewController?,
                            to toViewController: UIViewController?) {
    if fromViewController != nil {
      fromViewController!.willMove(toParentViewController: nil)
      fromViewController!.view.removeFromSuperview()
      fromViewController!.removeFromParentViewController()
    }
    
    if toViewController != nil {
      self.addChildViewController(toViewController!)
      self.view.insertSubview(toViewController!.view, at: 0)
      toViewController!.didMove(toParentViewController: self)
    }
  }
  

  func switchViews() {
    // Create the new view controller, if required
    if gameViewController?.view.superview == nil {
      if gameViewController == nil {
        gameViewController = storyboard?.instantiateViewController(withIdentifier: "Game")
          as! GameViewController
        gameViewController.switchingViewController = self
      }
    }
    else if startViewController?.view.superview == nil {
      if startViewController == nil {
        startViewController = storyboard?.instantiateViewController(withIdentifier: "Start")
          as! StartViewController
        startViewController.switchingViewController = self
      }
    }
    
    UIView.beginAnimations("Flip", context: nil)
    UIView.setAnimationDuration(1.0)
    UIView.setAnimationCurve(.easeInOut)
    
    // Switch view controllers
    if startViewController != nil &&
       startViewController.view.superview != nil {
      // If the blue view controller exists and its view is the one
      // currently being displayed in the switching view,
      // switch to the yellow view controller.
      UIView.setAnimationTransition(.curlUp, for: view, cache: true)
      gameViewController.view.frame = view.frame
      switchViewController(from: startViewController, to: gameViewController)
      gameViewController.beginGame()
    }
    else {
      // If the yellow view controller exists and its view is the one
      // currently being displayed in the switching view,
      // switch to the blue view controller.
      UIView.setAnimationTransition(.curlDown, for: view, cache: true)
      startViewController.view.frame = view.frame
      switchViewController(from: gameViewController, to: startViewController)
    }
    
    UIView.commitAnimations()
  }

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
