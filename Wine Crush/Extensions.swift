//
//  Chain.swift
//  Wine Crush
//
//  Created by Matthijs Hollemans on 19-06-14.
//  Copyright © 2014 Razeware LLC. All rights reserved.
//  MIT License. See the end of the file for the gory details.
//

import Foundation

extension Dictionary {

  // Loads a JSON file from the app bundle into a new dictionary
  static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
    if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {

      var error: NSError?
      let data: NSData?
      do {
        data = try NSData(contentsOfFile: path, options: NSDataReadingOptions())
      } catch let error1 as NSError {
        error = error1
        data = nil
      }
      if let data = data {

        let dictionary: AnyObject?
        do {
          dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
        } catch let error1 as NSError {
          error = error1
          dictionary = nil
        }
        if let dictionary = dictionary as? Dictionary<String, AnyObject> {
          return dictionary
        } else {
          print("Level file '\(filename)' is not valid JSON: \(error!)")
          return nil
        }
      } else {
        print("Could not load level file: \(filename), error: \(error!)")
        return nil
      }
    } else {
      print("Could not find level file: \(filename)")
      return nil
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
