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
class GameManager: SquareDelegate {
  
  var delegate: GameManagerDelegate?
  
  class var sharedInstance : GameManager {
    struct Static {
      static let instance = GameManager()
    }
    return Static.instance
  }
  
  /**
  マスの初期化
  */
  func initButtleField() {
    let gameData = GameData.sharedInstance
    let setting = gameData.setting;
    var squares = gameData.squares
    
    for i in 0..<setting.fieldWidth {
      var squareRow = [Square]()
      
      for j in 0..<setting.fieldHeight {
        let btn = Square(position: (i, j))
        btn.delegate = self
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
    
    gameData.squares = squares
  }

  /**
  ゲーム終了時の処理メソッド
  
  :param: gameResult ゲームの結果の種類
  */
  func finishGame(gameResult: GameResult) {
    delegate?.resultView?.hidden = false
  }
  
  /**
  *  ゲームを最初からやり直すときに呼ぶメソッド
  */
  func restartGame() {
    // ゲーム終了画面を消す
    delegate?.resultView?.hidden = true
    // マスを一旦すべて削除
    for square in delegate?.buttleField?.subviews as [UIView] {
      square.removeFromSuperview()
    }
    // ゲームデータの初期化
    GameData.sharedInstance.resetAllData()
    // 初期化
    initButtleField()
  }
}