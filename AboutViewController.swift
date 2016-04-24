//
//  AboutViewController.swift
//  Wine Crush
//
//  Created by Jose Martin DeVilla on 3/13/16.
//  Copyright © 2016 Joey deVilla. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UIWebViewDelegate {
  
  @IBOutlet weak var aboutWebView: UIWebView!

  override func viewDidLoad() {
    aboutWebView.delegate = self
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

  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    
    let url: NSURL = request.URL!
    let isExternalLink: Bool = url.scheme == "http" || url.scheme == "https" || url.scheme == "mailto"
    if (isExternalLink && navigationType == UIWebViewNavigationType.LinkClicked) {
      return !UIApplication.sharedApplication().openURL(request.URL!)
    } else {
      return true
    }
  }
  
}


