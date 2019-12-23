//
//  Path.swift
//  TD School Project
//
//  Created by Jack Darlison on 25/11/2019.
//  Copyright © 2019 Jack Darlison. All rights reserved.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

class Path {
    let rows: Int // = 10
    let columns: Int // = 10
    var grid: [[Int]]
    var path: [(Int,Int)]
    let start: (Int,Int)
    var goal = false
    
    init(_rows: Int, _columns: Int) {
        self.rows = _rows
        self.columns = _columns
        self.grid = Array(repeating: Array(repeating: 0, count: columns), count: rows)
        self.start = (Int.random(in: 1..<rows), 0)
        self.path = []
        var length: Int?
        while length ?? 0 < 60 {
            self.path = []
            self.grid = Array(repeating: Array(repeating: 0, count: columns), count: rows)
            self.goal = false
            path(xy: start, previous: (1,0))
            length = pathLength(start: start)
            
        }
//        for array in grid {
//            for value in array {
//                print(value, terminator: " ")
//            }
//            print(" ")
//        }
//        print(length!)
//        print(path)
        
        
    }

    func path(xy: (Int,Int), previous: (Int,Int)) {
        
        if goal {
            return
        }
        
        var count = 0
        
        for i in -1...1 {
            for j in -1...1 {
                if (i == 0 || j == 0) && i != j {
                    if grid[safe: xy.0 + i]?[safe: xy.1 + j] == 1 {
                        count += 1
                    }
                }
            }
        }
        
        if count <= 1 && 0..<rows ~= xy.0 && 0..<columns ~= xy.1 {
            grid[xy.0][xy.1] = 1
            path.append((xy.0, xy.1))
            if xy.1 == columns-1 {
                goal = true
            }
            let options = [(-1,0),(1,0),(0,-1),(0,1)].shuffled()
            for recursion in options {
                if recursion == (previous.0 * -1, previous.1 * -1) {
                    continue
                }
                path(xy: (xy.0+recursion.0, xy.1+recursion.1), previous: recursion)
            }
        } else {
            return
        }
        
        return
        
    }

    func pathLength(start: (Int, Int)) -> Int? {
        var length: Int = 1
        var currentPosition: (Int,Int) = start
        var lastMove: (Int,Int) = (1,0)
        while true {
            var count = 0
            var moves: [(Int,Int)] = []
            for i in -1...1 {
                for j in -1...1 {
                    if ( i == 0 || j == 0 ) && i != j {
                        if grid[safe: currentPosition.0 + i]?[safe: currentPosition.1 + j] == 1 {
                            if (i,j) != (lastMove.0 * -1, lastMove.1 * -1) {
                                moves.append((i,j))
                                count += 1
                            }
                        }
                    }
                }
            }
            if count > 1 {
                return nil
            }
            lastMove = moves[0]
            currentPosition = (currentPosition.0 + moves[0].0, currentPosition.1 + moves[0].1)
            length += 1
            if currentPosition.1 == columns-1 {
                return length
            }
            
        }
        
    }
}




