//
//  Chain.swift
//  Wine Crush
//
//  Created by Matthijs Hollemans on 19-06-14.
//  Copyright © 2014 Razeware LLC. All rights reserved.
//  MIT License. See the end of the file for the gory details.
//

class Chain: Hashable, CustomStringConvertible {
  // The Cookies that are part of this chain.
  var cookies = [Cookie]()

  enum ChainType: CustomStringConvertible {
    case Horizontal
    case Vertical

    // Note: add any other shapes you want to detect to this list.
    //case ChainTypeLShape
    //case ChainTypeTShape

    var description: String {
      switch self {
      case .Horizontal: return "Horizontal"
      case .Vertical: return "Vertical"
      }
    }
  }

  // Whether this chain is horizontal or vertical.
  var chainType: ChainType

  // How many points this chain is worth.
  var score = 0

  init(chainType: ChainType) {
    self.chainType = chainType
  }

  func addCookie(cookie: Cookie) {
    cookies.append(cookie)
  }

  func firstCookie() -> Cookie {
    return cookies[0]
  }

  func lastCookie() -> Cookie {
    return cookies[cookies.count - 1]
  }

  var length: Int {
    return cookies.count
  }

  var description: String {
    return "type:\(chainType) cookies:\(cookies)"
  }

  var hashValue: Int {
    return cookies.reduce(0) { $0.hashValue ^ $1.hashValue }
  }
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
  return lhs.cookies == rhs.cookies
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
