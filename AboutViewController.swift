//
//  StartViewController.swift
//  Wine Crush
//
//  Created by Joey deVilla on 2016-02-12.
//  Copyright © 2016 Joey deVilla. All rights reserved.
//  MIT License. See the end of the file for the gory details.
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
  
  @IBAction func backButtonPressed(sender: UIButton) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    let url: NSURL = request.URL!
    let isExternalLink: Bool = url.scheme == "http" || url.scheme == "https" || url.scheme == "mailto" || url.scheme == "tel"
    if (isExternalLink && navigationType == UIWebViewNavigationType.LinkClicked) {
      return !UIApplication.sharedApplication().openURL(request.URL!)
    } else {
      return true
    }
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


