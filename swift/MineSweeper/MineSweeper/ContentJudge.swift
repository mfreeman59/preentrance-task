//
//  ContentJudge.swift
//  MineSweeper
//
//  Created by 松田 健吾 on 2015/02/04.
//  Copyright (c) 2015年 Kengo Matsuda. All rights reserved.
//

private enum PositionType {
  case Corner, Side, Inside
}

class ContentJudge {
  
  class var sharedInstance : ContentJudge {
    struct Static {
      static let instance = ContentJudge()
    }
    return Static.instance
  }
  
  private init() {}
  
  /**
  まわりのマスを検索し、爆弾の数を返すメソッド
  
  :param: square 判別対象のマス
  
  :returns: まわりの爆弾の数
  */
  func judgeNumber(square: Square) -> ContentType {
    // 確認対象の周囲のマスの位置を格納
    var bombCount: Int = 0
    let row = square.position.0
    let column = square.position.1
    let squarePositions = getSurroundSquarePositions(square)
    
    // 爆弾のカウント
    for position in squarePositions {
      let targetSquare: Square = GameData.sharedInstance.squares[position.0][position.1]

      if targetSquare.isBomb {
        bombCount++
      }
    }
    
    println("\(square.position)、爆弾\(bombCount)個周囲にあり。")
    
    // 「空」だった場合は、隣接マスを自動開放
    if bombCount == 0 {
      println("\(square.position)が「空」。自動開放実行。")
      
      for position in squarePositions {
        println("\(position)：\(square.position)による自動開放")
        
        let targetSquare: Square = GameData.sharedInstance.squares[position.0][position.1]
        targetSquare.state.doTouchUp(targetSquare)
      }
    }
    
    println("\(square.position)、自動開放せず。")
    
    return ContentType(rawValue: bombCount)!
  }
  
  /**
  検索対象のマスの位置の配列を返す
  
  :param: square 起点となるマス
  
  :returns: まわりのマスの位置
  */
  private func getSurroundSquarePositions(square: Square) -> [(Int, Int)] {
    let row = square.position.0
    let column = square.position.1
    
    // 一旦ありうるポジションを全て代入
    var squarePositions = [
      (row - 1, column - 1), (row - 1, column), (row - 1, column + 1),
      (row, column - 1), (row, column + 1),
      (row + 1, column - 1), (row + 1, column), (row + 1, column + 1),
    ]
    
    // フィールドの外のものは外す
    return squarePositions.filter({
      let x = $0.0
      let y = $0.1
      let setting = GameData.sharedInstance.setting
      let fieldWidth = setting.fieldWidth
      let fieldHeight = setting.fieldHeight
      
      return 0...fieldWidth-1 ~= x && 0...fieldHeight-1 ~= y
    })
  }
}
