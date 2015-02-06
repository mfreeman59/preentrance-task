//
//  GameManager.swift
//  MineSweeper
//
//  Created by 松田 健吾 on 2015/02/01.
//  Copyright (c) 2015年 Kengo Matsuda. All rights reserved.
//

import UIKit

protocol GameManagerDelegate {
  var buttleField:UIView? { get }
  var switchTapMode:UISegmentedControl? { get }
  var resultView:UIView? { get }
  var resultText:UILabel? { get }
}

/**
*  ゲーム進行を管理するクラス
*/
class GameManager {
  
  var delegate: GameManagerDelegate?
  
  class var sharedInstance : GameManager {
    struct Static {
      static let instance = GameManager()
    }
    return Static.instance
  }
  
  // 定数
  struct Const {
    static let txtGameOver = "GAME OVER"
    static let txtGameClear = "GAME CLEAR"
  }
  
  private init() {}
  
  /**
  マスの初期化
  */
  func initButtleField() {
    
    println("------------フィールド初期化------------")
    
    let gameData = GameData.sharedInstance
    let setting = gameData.setting
    var squares = gameData.squares
    
    // マスの数に合わせて、マスの大きさを決定
    let sideLengthX = setting.sideLength / setting.fieldWidth
    let sideLengthY = setting.sideLength / setting.fieldHeight
    setting.squareSize = min(sideLengthX, sideLengthY)
    
    // ボタンの初期化＆位置のセット
    for i in 0..<setting.fieldWidth {
      var squareRow = [Square]()
      
      for j in 0..<setting.fieldHeight {
        let btn = Square(position: (i, j))
        // マスの追加＆位置の決定
        delegate?.buttleField?.addSubview(btn)
        btn.frame = CGRectMake(CGFloat(
          setting.squareSize * j),
          CGFloat(setting.squareSize * i),
          CGFloat(setting.squareSize),
          CGFloat(setting.squareSize)
        )
        // 位置情報とともにマスの情報を保存
        squareRow.append(btn)
      }
      
      // 各行の情報を格納
      squares.append(squareRow)
    }
    
    // 爆弾をすべて使わなかった場合、もう一度init
    if setting.unsetBombCount != 0 {
      println("未設定爆弾あり。再読み込み。")
      resetGame()
      return
    }

    // 各マスの周囲にある爆弾数を計算
    gameData.squares = squares
    countSurroundBombs(&gameData.squares)
  }

  /**
  各マスの周囲の爆弾数を計算
  
  :param: squares フィールド上にあるマスの２重配列
  */
  private func countSurroundBombs(inout squares: [[Square]]) {

    for squareRow in squares {
      for square in squareRow {
        // 一つ一つのマスの処理
        let surroundSquarePositions: [(Int, Int)] = square.getSurroundSquarePositions()
        var bombCount: Int = 0
        
        for position in surroundSquarePositions {
          let targetSquare: Square = GameData.sharedInstance.squares[position.0][position.1]
          
          if targetSquare.isBomb {
            bombCount++
          }
        }
        
        square.bombCount = bombCount
      }
    }
  }

  /**
  *  ゲームが終了したか判定するメソッド
  */
  func judgeGameIsCleared() {
    let gameData = GameData.sharedInstance
    let flagUnused = gameData.flagUnused
    let bombUnflagged = gameData.bombUnflagged
    
    println("残りの未使用フラグ数： \(flagUnused)")
    println("残りの爆弾の数： \(bombUnflagged)")
    
    // すべてのマスが開き、爆弾もぴったりフラグが立てられた場合
    if flagUnused == 0 && bombUnflagged == 0 {
      // 自動開放時に「旗」が立たない設定
      GameData.sharedInstance.tapMode = TapMode.Open
      
      // 開いていないマスを自動開放
      for squareRow in gameData.squares {
        for square in squareRow {
          if square.state.getType(square) == SquareStateType.Empty {
            square.state.doTouchUp(square)
          }
        }
      }
      // 終了ロジック
      GameManager.sharedInstance.finishGame(GameResult.Clear)
    }
  }

  /**
  ゲーム終了時の処理メソッド
  
  :param: gameResult ゲームの結果の種類
  */
  func finishGame(gameResult: GameResult) {
    delegate?.resultView?.hidden = false
    
    if gameResult == GameResult.Clear {
      delegate?.resultText?.text = Const.txtGameClear
    } else {
      delegate?.resultText?.text = Const.txtGameOver
    }
  }
  
  /**
  *  ゲームを最初からやり直すときに呼ぶメソッド
  */
  func resetGame() {
    // ゲーム終了画面を消す
    delegate?.resultView?.hidden = true
    // マスを一旦すべて削除
    for square in delegate?.buttleField?.subviews as [UIView] {
      square.removeFromSuperview()
    }
    // タップモード初期化
    GameData.sharedInstance.tapMode = TapMode.Open
    delegate?.switchTapMode?.selectedSegmentIndex = TapMode.Open.rawValue
    // ゲームデータの初期化
    GameData.sharedInstance.resetAllData()
    // 初期化
    initButtleField()
  }
}