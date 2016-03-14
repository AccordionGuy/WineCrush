//
//  AboutViewController.swift
//  Wine Crush
//
//  Created by Jose Martin DeVilla on 3/13/16.
//  Copyright © 2016 Joey deVilla. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
  
  @IBOutlet weak var aboutWebView: UIWebView!

  override func viewDidLoad() {
    loadWebView()
  }
  
  func loadWebView() {
    if let htmlFile = NSBundle.mainBundle().pathForResource("about", ofType: "html") {
      if let htmlData = NSData(contentsOfFile: htmlFile) {
        let baseURL = NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath)
        aboutWebView.loadData(htmlData,
                              MIMEType: "text/html",
                              textEncodingName: "UTF-8",
                              baseURL: baseURL)
      }
    }
  }
  
  @IBAction func backButtonPressed(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}
