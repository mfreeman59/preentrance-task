//
//  Square.swift
//  MineSweeper
//
//  Created by 松田 健吾 on 2015/02/01.
//  Copyright (c) 2015年 Kengo Matsuda. All rights reserved.
//

import UIKit

/**
*  マスのStateの抽象クラス
*/
protocol SquareState {
  /**
  タップ押下時のイベントリスナー
  
  :param: square マスのインスタンス
  */
  func doTouchDown(square: Square)
  
  /**
  タップを離した時のイベントリスナー
  
  :param: square マスのインスタンス
  */
  func doTouchUp(square: Square)

  /**
  Stateをenumで返す
  
  :param: square マスのインスタンス
  */
  func getType(square: Square) -> SquareStateType
  
}

// TODO: このクラス、全体的にリファクタする
/**
*  マスのクラス
*/
class Square : UIImageView {

  /// マスの状態を保持するプロパティ
  var state : SquareState = EmptyState.sharedInstance
  /// 旗を立てられても（Stateが変わっても）保持する爆弾フラグ
  var isBomb = false
  /// フィールド上の位置
  let position : (Int, Int)

  // 定数
  struct Const {
    static let imgBtnName = "btn"
    static let imgBtnOverName = "btn_over"
    static let imgBombName = "bomb"
    static let imgFlagName = "flag"
  }
    
  /**
  イニシャライザ。ここで爆弾を保持するかどうかを決定
  
  :param: position フィールド上の位置
  */
  init(position : (Int, Int)) {

    self.position = position

    // スーパークラスのイニシャライザ
    super.init(image: UIImage(named: Const.imgBtnName))
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
  
  
  // TODO: 地雷チェックのところの分岐も親クラスにまとめたい
  // TODO: Imageファイル名のハードコーディングをどうにかする
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
      square.image = UIImage(named: Const.imgBtnOverName)
    }
    
    private func doTouchUp(square: Square) {
      let tapMode: TapMode = GameData.sharedInstance.tapMode
      
      if tapMode == TapMode.CheckBomb {
        // フラグを立てる
        square.image = UIImage(named: Const.imgFlagName)
        square.state = FlagState.sharedInstance
        GameData.sharedInstance.flagUnused--
      } else {
        // 周囲の爆弾の数を計算し、数を表示
        square.state = OpenState.sharedInstance
        let bombCount: ContentType = ContentJudge.sharedInstance.judgeNumber(square)
        let imageName: String = ContentType.getImageName(bombCount)
        square.image = UIImage(named: imageName)
      }

      GameManager.sharedInstance.judgeGameIsCleared()
    }
    
    private func getType(square: Square) -> SquareStateType {
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
    
    private func getType(square: Square) -> SquareStateType {
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
      square.image = UIImage(named: Const.imgBtnOverName)
    }
    
    private func doTouchUp(square: Square) {
      let tapMode: TapMode = GameData.sharedInstance.tapMode
      let gameData = GameData.sharedInstance
      
      if tapMode == TapMode.CheckBomb {
        square.image = UIImage(named: Const.imgFlagName)
        square.state = FlagState.sharedInstance
        
        // クリア判定のための数値の変更
        if square.isBomb {
          gameData.bombUnflagged--
          println("残りの爆弾の数： \(gameData.bombUnflagged)")
        }
        gameData.flagUnused--
        
        // クリア判定
        GameManager.sharedInstance.judgeGameIsCleared()
      } else {
        square.image = UIImage(named: Const.imgBombName)
        GameManager.sharedInstance.finishGame(GameResult.Gameover)
        println("-----------GAMEOVER-----------")
      }
    }
    
    private func getType(square: Square) -> SquareStateType {
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
    
    private func doTouchDown(square: Square) {}
    
    private func doTouchUp(square: Square) {
      let gameData = GameData.sharedInstance
      let tapMode: TapMode = GameData.sharedInstance.tapMode
      
      if tapMode == TapMode.CheckBomb {
        square.image = UIImage(named: Const.imgBtnName)

        if square.isBomb {
          square.state = BombState.sharedInstance
          gameData.bombUnflagged++
          println("残りの爆弾の数： \(GameData.sharedInstance.bombUnflagged)")
        } else {
          square.state = EmptyState.sharedInstance
        }
        
        gameData.flagUnused++
      }
    }
    
    private func getType(square: Square) -> SquareStateType {
      return SquareStateType.Flag
    }
  }
}