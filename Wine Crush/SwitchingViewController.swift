//
//  SwitchingViewController.swift
//  ViewSwitcher
//
//  Created by Jose Martin DeVilla on 2/14/16.
//  Copyright © 2016 Joey deVilla. All rights reserved.
//

import UIKit

class SwitchingViewController: UIViewController {
  
  private var startViewController: StartViewController!
  private var gameViewController: GameViewController!
  

  override func viewDidLoad() {
    super.viewDidLoad()

    gameViewController = storyboard?.instantiateViewControllerWithIdentifier("Game")
      as! GameViewController
    gameViewController.switchingViewController = self
    
    startViewController = storyboard?.instantiateViewControllerWithIdentifier("Start")
      as! StartViewController
    startViewController.switchingViewController = self
    startViewController.view.frame = view.frame
    switchViewController(from: nil, to: startViewController)
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
      fromViewController!.willMoveToParentViewController(nil)
      fromViewController!.view.removeFromSuperview()
      fromViewController!.removeFromParentViewController()
    }
    
    if toViewController != nil {
      self.addChildViewController(toViewController!)
      self.view.insertSubview(toViewController!.view, atIndex: 0)
      toViewController!.didMoveToParentViewController(self)
    }
  }
  

  func switchViews() {
    // Create the new view controller, if required
    if gameViewController?.view.superview == nil {
      if gameViewController == nil {
        gameViewController = storyboard?.instantiateViewControllerWithIdentifier("Game")
          as! GameViewController
        gameViewController.switchingViewController = self
      }
    }
    else if startViewController?.view.superview == nil {
      if startViewController == nil {
        startViewController = storyboard?.instantiateViewControllerWithIdentifier("Start")
          as! StartViewController
        startViewController.switchingViewController = self
      }
    }
    
    UIView.beginAnimations("Flip", context: nil)
    UIView.setAnimationDuration(1.0)
    UIView.setAnimationCurve(.EaseInOut)
    
    // Switch view controllers
    if startViewController != nil &&
       startViewController.view.superview != nil {
      // If the blue view controller exists and its view is the one
      // currently being displayed in the switching view,
      // switch to the yellow view controller.
      UIView.setAnimationTransition(.CurlUp, forView: view, cache: true)
      gameViewController.view.frame = view.frame
      switchViewController(from: startViewController, to: gameViewController)
      gameViewController.beginGame()
    }
    else {
      // If the yellow view controller exists and its view is the one
      // currently being displayed in the switching view,
      // switch to the blue view controller.
      UIView.setAnimationTransition(.CurlDown, forView: view, cache: true)
      startViewController.view.frame = view.frame
      switchViewController(from: gameViewController, to: startViewController)
    }
    
    UIView.commitAnimations()
  }

}
