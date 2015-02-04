//
//  Square.swift
//  MineSweeper
//
//  Created by 松田 健吾 on 2015/02/01.
//  Copyright (c) 2015年 Kengo Matsuda. All rights reserved.
//

import UIKit

/**
*  GameManagerへの委譲用プロトコル
*/
protocol SquareDelegate {
  func finishGame(gameResult: GameResult)
}

/**
*  マスのStateへのプロトコル
*/
private protocol SquareState {
  func doTouchDown(square: Square) // タップ押下時
  func doTouchUp(square: Square)   // タップを離した時
}

/**
*  マスのクラス
*/
class Square : UIImageView {

  /// GameMasterへのデリゲート
  var delegate: SquareDelegate?
  /// マスの状態を保持するプロパティ
  private var state : SquareState = EmptyState.sharedInstance
  /// フィールド上の位置
  let position : (Int, Int)
  
  /**
  イニシャライザ。ここで爆弾を保持するかどうかを決定
  
  :param: position フィールド上の位置
  */
  init(position : (Int, Int)) {

    self.position = position

    // スーパークラスのイニシャライザ
    super.init(image: UIImage(named: "btn"))
    self.userInteractionEnabled = true

    // 爆弾をセット
    if canSetBomb() {
      self.state = BombState.sharedInstance
      println("Bomb is in \(position)")
    }
  }
  
  /**
  自動生成のイニシャライザ
  */
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /**
  タップ押下時の処理
  */
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    state.doTouchDown(self)
  }
  
  /**
  タップを離した時の処理
  */
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    state.doTouchUp(self)
  }
  
  /**
  爆弾をセットするマスか判定するメソッド
  とりあえず、1/2の確率で単純に判定する
  
  :returns: 爆弾をセットするときはtrueを返す
  */
  func canSetBomb() -> Bool {
    let randNum = Int(arc4random() % 2)
    let setting = GameData.sharedInstance.setting
    let unsetBombCount = setting.unsetBombCount
    
    if randNum == 0 && 0 < unsetBombCount {
      setting.unsetBombCount--
      return true
    } else {
      return false
    }
  }
  
  
  // TODO: 各Stateを個々のファイルに分ける
  /**
  *  爆弾でなく、かつ開いていないマスのStateクラス
  */
  private class EmptyState: SquareState {
    class var sharedInstance: EmptyState {
      struct Static {
        static let instance = EmptyState()
      }
      return Static.instance
    }
    
    /**
    ボタンを押した画像に変更。
    
    :param: square マスのインスタンス
    */
    private func doTouchDown(square: Square) {
      square.image = UIImage(named: "btn_over")
    }
    
    private func doTouchUp(square: Square) {
      square.image = UIImage(named: "btn")
      
      
    }
  }
  
  /**
  *  すでに開いているマスのStateクラス
  */
  private class OpenState: SquareState {
    class var sharedInstance: OpenState {
      struct Static {
        static let instance = OpenState()
      }
      return Static.instance
    }
    
    /**
    何もしない
    
    :param: square マスのインスタンス
    */
    private func doTouchDown(square: Square) {}
    private func doTouchUp(square: Square) {}
  }
  
  /**
  *  爆弾が入っているマスのStateクラス
  */
  private class BombState: SquareState {
    class var sharedInstance: BombState {
      struct Static {
        static let instance = BombState()
      }
      return Static.instance
    }
    
    private func doTouchDown(square: Square) {
      
    }
    
    private func doTouchUp(square: Square) {
      square.image = UIImage(named: "bomb")
      square.delegate?.finishGame(GameResult.Gameover)
      println("-----------GAMEOVER-----------")
    }
  }
  
  /**
  *  地雷チェックがされているマスのStateクラス
  */
  private class FlagState: SquareState {
    class var sharedInstance: FlagState {
      struct Static {
        static let instance = FlagState()
      }
      return Static.instance
    }
    
    private func doTouchDown(square: Square) {
      
    }
    
    private func doTouchUp(square: Square) {
      
    }
  }
}