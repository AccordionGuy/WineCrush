//
//  Level.swift
//  Wine Crush
//
//  Created by Joey deVilla on 2016-02-10.
//  Copyright © 2016 Joey deVilla. All rights reserved.
//  Based on code by Matthijs Hollemans on 19-06-14.
//  Copyright © 2014 Razeware LLC. All rights reserved.
//  MIT License. See the end of the file for the gory details.
//

import Foundation

let NumColumns = 9
let NumRows = 9

class Level {
  
  // The 2D array that keeps track of where the Cookies are.
  fileprivate var cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)

  // The 2D array that contains the layout of the level.
  fileprivate var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)

  // The list of swipes that result in a valid swap. Used to determine whether
  // the player can make a certain swap, whether the board needs to be shuffled,
  // and to generate hints.
  fileprivate var possibleSwaps = Set<Swap>()

  var targetScore = 0
  var maximumMoves = 0

  // The second chain gets twice its regular score, the third chain three times,
  // and so on. This multiplier is reset for every next turn.
  fileprivate var comboMultiplier = 0

  // Create a level by loading it from a file.
  init(filename: String) {

    if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {

      // The dictionary contains an array named "tiles". This array contains
      // one element for each row of the level. Each of those row elements in
      // turn is also an array describing the columns in that row. If a column
      // is 1, it means there is a tile at that location, 0 means there is not.
      if let tilesArray: AnyObject = dictionary["tiles"] {

        // Loop through the rows...
        for (row, rowArray) in (tilesArray as! [[Int]]).enumerated() {

          // Note: In Sprite Kit (0,0) is at the bottom of the screen,
          // so we need to read this file upside down.
          let tileRow = NumRows - row - 1

          // Loop through the columns in the current row...
          for (column, value) in rowArray.enumerated() {

            // If the value is 1, create a tile object.
            if value == 1 {
              tiles[column, tileRow] = Tile()
            }
          }
        }

        targetScore = dictionary["targetScore"] as! Int
        maximumMoves = dictionary["moves"] as! Int
      }
    }
  }

  // MARK: Game Setup

  // Fills up the level with new Cookie objects. The level is guaranteed free
  // from matches at this point.
  // You call this method at the beginning of a new game and whenever the player
  // taps the Shuffle button.
  // Returns a set containing all the new Cookie objects.
  func shuffle() -> Set<Cookie> {
    var set: Set<Cookie>

    repeat {
      // Removes the old cookies and fills up the level with all new ones.
      set = createInitialCookies()

      // At the start of each turn we need to detect which cookies the player can
      // actually swap. If the player tries to swap two cookies that are not in
      // this set, then the game does not accept this as a valid move.
      // This also tells you whether no more swaps are possible and the game needs
      // to automatically reshuffle.
      detectPossibleSwaps()

      //println("possible swaps: \(possibleSwaps)")

      // If there are no possible moves, then keep trying again until there are.
    }
    while possibleSwaps.count == 0
    
    debugCookies()

    return set
  }

  fileprivate func createInitialCookies() -> Set<Cookie> {
    var set = Set<Cookie>()

    // Loop through the rows and columns of the 2D array. Note that column 0,
    // row 0 is in the bottom-left corner of the array.
    for row in 0..<NumRows {
      for column in 0..<NumColumns {

        // Only make a new cookie if there is a tile at this spot.
        if tiles[column, row] != nil {

          // Pick the cookie type at random, and make sure that this never
          // creates a chain of 3 or more. We want there to be 0 matches in
          // the initial state.
          var cookieType: CookieType
          repeat {
            cookieType = CookieType.random()
          }
          while (column >= 2 &&
                  cookies[column - 1, row]?.cookieType == cookieType &&
                  cookies[column - 2, row]?.cookieType == cookieType)
             || (row >= 2 &&
                  cookies[column, row - 1]?.cookieType == cookieType &&
                  cookies[column, row - 2]?.cookieType == cookieType)

          // Create a new cookie and add it to the 2D array.
          let cookie = Cookie(column: column, row: row, cookieType: cookieType)
          cookies[column, row] = cookie

          // Also add the cookie to the set so we can tell our caller about it.
          set.insert(cookie)
        }
      }
    }
    return set
  }

  // MARK: Querying the Level

  // Returns the cookie at the specified column and row, or nil when there is none.
  func cookieAtColumn(_ column: Int, row: Int) -> Cookie? {
    assert(column >= 0 && column < NumColumns)
    assert(row >= 0 && row < NumRows)
    return cookies[column, row]
  }

  // Determines whether there's a tile at the specified column and row.
  func tileAtColumn(_ column: Int, row: Int) -> Tile? {
    assert(column >= 0 && column < NumColumns)
    assert(row >= 0 && row < NumRows)
    return tiles[column, row]
  }

  // Determines whether the suggested swap is a valid one, i.e. it results in at
  // least one new chain of 3 or more cookies of the same type.
  func isPossibleSwap(_ swap: Swap) -> Bool {
    return possibleSwaps.contains(swap)
  }

  // MARK: Swapping

  // Swaps the positions of the two cookies from the Swap object.
  func performSwap(_ swap: Swap) {
    // Need to make temporary copies of these because they get overwritten.
    let columnA = swap.cookieA.column
    let rowA = swap.cookieA.row
    let columnB = swap.cookieB.column
    let rowB = swap.cookieB.row

    // Swap the cookies. We need to update the array as well as the column
    // and row properties of the Cookie objects, or they go out of sync!
    cookies[columnA, rowA] = swap.cookieB
    swap.cookieB.column = columnA
    swap.cookieB.row = rowA

    cookies[columnB, rowB] = swap.cookieA
    swap.cookieA.column = columnB
    swap.cookieA.row = rowB
  }

  // MARK: Detecting Swaps

  // Recalculates which moves are valid.
  func detectPossibleSwaps() {
    var set = Set<Swap>()

    for row in 0..<NumRows {
      for column in 0..<NumColumns {
        if let cookie = cookies[column, row] {

          // Is it possible to swap this cookie with the one on the right?
          // Note: don't need to check the last column.
          if column < NumColumns - 1 {

            // Have a cookie in this spot? If there is no tile, there is no cookie.
            if let other = cookies[column + 1, row] {
              // Swap them
              cookies[column, row] = other
              cookies[column + 1, row] = cookie

              // Is either cookie now part of a chain?
              if hasChainAtColumn(column + 1, row: row) ||
                 hasChainAtColumn(column, row: row) {
                set.insert(Swap(cookieA: cookie, cookieB: other))
              }

              // Swap them back
              cookies[column, row] = cookie
              cookies[column + 1, row] = other
            }
          }

          // Is it possible to swap this cookie with the one above?
          // Note: don't need to check the last row.
          if row < NumRows - 1 {

            // Have a cookie in this spot? If there is no tile, there is no cookie.
            if let other = cookies[column, row + 1] {
              // Swap them
              cookies[column, row] = other
              cookies[column, row + 1] = cookie

              // Is either cookie now part of a chain?
              if hasChainAtColumn(column, row: row + 1) ||
                 hasChainAtColumn(column, row: row) {
                set.insert(Swap(cookieA: cookie, cookieB: other))
              }

              // Swap them back
              cookies[column, row] = cookie
              cookies[column, row + 1] = other
            }
          }
        }
      }
    }

    possibleSwaps = set
  }

  fileprivate func hasChainAtColumn(_ column: Int, row: Int) -> Bool {
    // Here we do ! because we know there is a cookie here
    let cookieType = cookies[column, row]!.cookieType

    // Here we do ? because there may be no cookie there; if there isn't then
    // the loop will terminate because it is != cookieType. (So there is no
    // need to check whether cookies[i, row] != nil.)
    var horzLength = 1

    // Left
    var i = column - 1
    while i >= 0 && cookies[i, row]?.cookieType == cookieType {
      i -= 1
      horzLength += 1
    }
    
    // Right
    i = column + 1
    while i < NumColumns && cookies[i, row]?.cookieType == cookieType {
      i += 1
      horzLength += 1
    }
    if horzLength >= 3 { return true }
    
    // Vertical chain check
    var vertLength = 1
    
    // Down
    i = row - 1
    while i >= 0 && cookies[column, i]?.cookieType == cookieType {
      i -= 1
      vertLength += 1
    }
    
    // Up
    i = row + 1
    while i < NumRows && cookies[column, i]?.cookieType == cookieType {
      i += 1
      vertLength += 1
    }
    return vertLength >= 3
  }

  // MARK: Detecting Matches

  // Detects whether there are any chains of 3 or more cookies, and removes
  // them from the level.
  // Returns a set containing Chain objects, which describe the Cookies
  // that were removed.
  func removeMatches() -> Set<Chain> {
    let horizontalChains = detectHorizontalMatches()
    let verticalChains = detectVerticalMatches()

    // Note: to detect more advanced patterns such as an L shape, you can see
    // whether a cookie is in both the horizontal & vertical chains sets and
    // whether it is the first or last in the array (at a corner). Then you
    // create a new Chain object with the new type and remove the other two.

    removeCookies(horizontalChains)
    removeCookies(verticalChains)

    calculateScores(horizontalChains)
    calculateScores(verticalChains)

    return horizontalChains.union(verticalChains)
  }

  fileprivate func detectHorizontalMatches() -> Set<Chain> {
    // Contains the Cookie objects that were part of a horizontal chain.
    // These cookies must be removed.
    var set = Set<Chain>()

    for row in 0..<NumRows {

      // Don't need to look at last two columns.
      var column = 0
      while column < NumColumns - 2 {

        // If there is a cookie/tile at this position...
        if let cookie = cookies[column, row] {
          let matchType = cookie.cookieType

          // And the next two columns have the same type...
          if cookies[column + 1, row]?.cookieType == matchType &&
             cookies[column + 2, row]?.cookieType == matchType {

            // ...then add all the cookies from this chain into the set.
            let chain = Chain(chainType: .horizontal)
            repeat {
              chain.addCookie(cookies[column, row]!)
              column += 1
            } while column < NumColumns &&
                    cookies[column, row]?.cookieType == matchType

            set.insert(chain)
            continue
          }
        }

        // Cookie did not match or empty tile, so skip over it.
        column += 1
      }
    }
    return set
  }

  // Same as the horizontal version but steps through the array differently.
  fileprivate func detectVerticalMatches() -> Set<Chain> {
    var set = Set<Chain>()

    for column in 0..<NumColumns {
      var row = 0
      while row < NumRows - 2 {
        if let cookie = cookies[column, row] {
          let matchType = cookie.cookieType

          if cookies[column, row + 1]?.cookieType == matchType &&
             cookies[column, row + 2]?.cookieType == matchType {

            let chain = Chain(chainType: .vertical)
            repeat {
              chain.addCookie(cookies[column, row]!)
              row += 1
            }
            while row < NumRows && cookies[column, row]?.cookieType == matchType

            set.insert(chain)
            continue
          }
        }
        row += 1
      }
    }
    return set
  }

  fileprivate func removeCookies(_ chains: Set<Chain>) {
    for chain in chains {
      for cookie in chain.cookies {
        cookies[cookie.column, cookie.row] = nil
      }
    }
  }

  fileprivate func calculateScores(_ chains: Set<Chain>) {
    // 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
    for chain in chains {
      chain.score = 60 * (chain.length - 2) * comboMultiplier
      comboMultiplier += 1
    }
  }

  // Should be called at the start of every new turn.
  func resetComboMultiplier() {
    comboMultiplier = 1
  }

  // MARK: Detecting Holes

  // Detects where there are holes and shifts any cookies down to fill up those
  // holes. In effect, this "bubbles" the holes up to the top of the column.
  // Returns an array that contains a sub-array for each column that had holes,
  // with the Cookie objects that have shifted. Those cookies are already
  // moved to their new position. The objects are ordered from the bottom up.
  func fillHoles() -> [[Cookie]] {
    var columns = [[Cookie]]()       // you can also write this Array<Array<Cookie>>

    // Loop through the rows, from bottom to top. It's handy that our row 0 is
    // at the bottom already. Because we're scanning from bottom to top, this
    // automatically causes an entire stack to fall down to fill up a hole.
    // We scan one column at a time.
    for column in 0..<NumColumns {
      var array = [Cookie]()

      for row in 0..<NumRows {

        // If there is a tile at this position but no cookie, then there's a hole.
        if tiles[column, row] != nil && cookies[column, row] == nil {

          // Scan upward to find a cookie.
          for lookup in (row + 1)..<NumRows {
            if let cookie = cookies[column, lookup] {
              // Swap that cookie with the hole.
              cookies[column, lookup] = nil
              cookies[column, row] = cookie
              cookie.row = row

              // For each column, we return an array with the cookies that have
              // fallen down. Cookies that are lower on the screen are first in
              // the array. We need an array to keep this order intact, so the
              // animation code can apply the correct kind of delay.
              array.append(cookie)

              // Don't need to scan up any further.
              break
            }
          }
        }
      }

      if !array.isEmpty {
        columns.append(array)
      }
    }
    return columns
  }

  // Where necessary, adds new cookies to fill up the holes at the top of the
  // columns.
  // Returns an array that contains a sub-array for each column that had holes,
  // with the new Cookie objects. Cookies are ordered from the top down.
  func topUpCookies() -> [[Cookie]] {
    var columns = [[Cookie]]()
    var cookieType: CookieType = .unknown

    // Detect where we have to add the new cookies. If a column has X holes,
    // then it also needs X new cookies. The holes are all on the top of the
    // column now, but the fact that there may be gaps in the tiles makes this
    // a little trickier.
    for column in 0..<NumColumns {
      var array = [Cookie]()

      // This time scan from top to bottom. We can end when we've found the
      // first cookie.
      var row = NumRows - 1
      while row >= 0 && cookies[column, row] == nil {

        // Found a hole?
        if tiles[column, row] != nil {

          // Randomly create a new cookie type. The only restriction is that
          // it cannot be equal to the previous type. This prevents too many
          // "freebie" matches.
          var newCookieType: CookieType
          repeat {
            newCookieType = CookieType.random()
          } while newCookieType == cookieType
          cookieType = newCookieType

          // Create a new cookie and add it to the array for this column.
          let cookie = Cookie(column: column, row: row, cookieType: cookieType)
          cookies[column, row] = cookie
          array.append(cookie)
        }
        
        row -= 1
      }

      if !array.isEmpty {
        columns.append(array)
      }
    }
    debugCookies()
    
    return columns
  }
  
  func hint() -> Swap? {
    return possibleSwaps.first
  }
  
  func swapsCount() -> Int {
    return possibleSwaps.count
  }
  
  func debugCookies() {
    var line: String
    print("Cookies")
    print("---------------------------------------")
    var row = NumRows - 1
    while row >= 0 {
      line = "\(row): "
      for column in 0 ..< NumColumns {
        if let cookie = cookies[column, row] {
          line += " \(cookie.cookieType.shortName) "
        }
        else {
          line += " .. "
        }
      }
      print(line)
      row -= 1
    }
    print("---------------------------------------")
    
    print("Possible swaps: \(possibleSwaps.count)")
    for swap in possibleSwaps {
      print(swap)
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
