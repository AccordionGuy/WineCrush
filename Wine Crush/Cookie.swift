//
//  Cookie.swift
//  Wine Crush
//
//  Created by Joey deVilla on 2016-02-10.
//  Copyright © 2016 Joey deVilla. All rights reserved.
//  Based on code by Matthijs Hollemans on 19-06-14.
//  Copyright © 2014 Razeware LLC. All rights reserved.
//  MIT License. See the end of the file for the gory details.
//

import SpriteKit

class Cookie: CustomStringConvertible, Hashable {
  var column: Int
  var row: Int
  let cookieType: CookieType
  var sprite: SKSpriteNode?

  init(column: Int, row: Int, cookieType: CookieType) {
    self.column = column
    self.row = row
    self.cookieType = cookieType
  }

  var description: String {
    return "type:\(cookieType) square:(\(column),\(row))"
  }

  var hashValue: Int {
    return row*10 + column
  }
}

enum CookieType: Int, CustomStringConvertible {
  case Unknown = 0, RedGlass, WhiteBottle, Grapes, Cheese, Cork, WhiteGlass

  var spriteName: String {
    let spriteNames = [
      "RedGlass",
      "WhiteBottle",
      "Grapes",
      "Cheese",
      "Cork",
      "WhiteGlass"]

    return spriteNames[rawValue - 1]
  }
  
  var shortName: String {
    let shortNames = [
      "RG",
      "WB",
      "Gr",
      "Ch",
      "Co",
      "WG"
    ]
    return shortNames[rawValue - 1]
  }

  var highlightedSpriteName: String {
    return spriteName + "-Highlighted"
  }

  static func random() -> CookieType {
    return CookieType(rawValue: Int(arc4random_uniform(6)) + 1)!
  }

  var description: String {
    return spriteName
  }
}

func ==(lhs: Cookie, rhs: Cookie) -> Bool {
  return lhs.column == rhs.column && lhs.row == rhs.row
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
