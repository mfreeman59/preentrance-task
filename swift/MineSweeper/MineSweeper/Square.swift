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
  func doTouchDown(square: Square)  // タップ押下時
  func doTouchUp(square: Square)    // タップを離した時
  func getStateType() -> SquareStateType // Stateのenumを返す
}

/**
*  マスのStateのenum
*/
enum SquareStateType {
  case Empty, Open, Bomb, Flag
}

/**
*  マスのクラス
*/
class Square : UIImageView {

  /// GameMasterへのデリゲート
  var delegate: SquareDelegate?
  /// マスの状態を保持するプロパティ
  private var state : SquareState = EmptyState.sharedInstance
  /// 旗を立てられても（Stateが変わっても）保持する爆弾フラグ
  var isBomb = false
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
      self.isBomb = true
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
  
  // TODO: 計算型プロパティで体現できないか模索
  /**
  マスのStateを返す
  
  :returns: Stateのenum
  */
  func getStateType() -> SquareStateType {
    return state.getStateType()
  }
  
  // TODO: 爆弾セットのアルゴリズム変更
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
  
  
  // TODO: EmptyStateとBombStateのTouchUp(ボタン押下時の切り替え)のことを考え、親クラスを作る
  // TODO: 地雷チェックのところの分岐も親クラスにまとめたい
  // TODO: Imageファイル名のハードコーディングをどうにかする
  // TODO: 間違ったものに旗をたてた時の処理
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
      let tapMode: TapMode = GameData.sharedInstance.tapMode
      
      if tapMode == TapMode.CheckBomb {
        square.image = UIImage(named: "flag")
        square.state = FlagState.sharedInstance
      } else {
        let bombCount: ContentType = ContentJudge.sharedInstance.judgeNumber(square)
        let imageName: String = ContentType.getImageName(bombCount)
        square.image = UIImage(named: imageName)
        square.state = OpenState.sharedInstance
      }
    }
    
    private func getStateType() -> SquareStateType {
      return SquareStateType.Empty
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
    
    private func getStateType() -> SquareStateType {
      return SquareStateType.Open
    }
  }
  
  /**
  *  爆弾が入っているマスのStateクラス（開いていない状態）
  */
  private class BombState: SquareState {
    class var sharedInstance: BombState {
      struct Static {
        static let instance = BombState()
      }
      return Static.instance
    }
    
    private func doTouchDown(square: Square) {
      square.image = UIImage(named: "btn_over")
    }
    
    private func doTouchUp(square: Square) {
      let tapMode: TapMode = GameData.sharedInstance.tapMode
      
      if tapMode == TapMode.CheckBomb {
        square.image = UIImage(named: "flag")
        square.state = FlagState.sharedInstance
      } else {
        square.image = UIImage(named: "bomb")
        square.delegate?.finishGame(GameResult.Gameover)
        println("-----------GAMEOVER-----------")
      }
    }
    
    private func getStateType() -> SquareStateType {
      return SquareStateType.Bomb
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
      square.image = UIImage(named: "btn_over")
    }
    
    private func doTouchUp(square: Square) {
      square.image = UIImage(named: "btn")
      square.state = EmptyState.sharedInstance
    }
    
    private func getStateType() -> SquareStateType {
      return SquareStateType.Flag
    }
  }
}