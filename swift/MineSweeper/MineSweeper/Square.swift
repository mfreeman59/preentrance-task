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

/**
*  マスに関わるロジックが書いてあるクラス
*/
class Square : UIImageView {

  /// マスの状態を保持するプロパティ
  var state : SquareState = EmptyState.sharedInstance
  /// 旗を立てられても（Stateが変わっても）保持する爆弾フラグ
  var isBomb = false
  /// フィールド上の位置
  let position : (Int, Int)
  /// 周囲の爆弾の数
  var bombCount: Int = 0

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
    let setting = GameData.sharedInstance.setting
    let unsetBombCount = setting.unsetBombCount
    let shouldHaveBomb = Int(arc4random() % UInt32(setting.squareCount)) <= setting.bombCount
    
    if shouldHaveBomb && 0 < unsetBombCount {
      setting.unsetBombCount--
      return true
    } else {
      return false
    }
  }
  
  /**
  検索対象のマスの位置の配列を返す
  
  :param: square 起点となるマス
  
  :returns: まわりのマスの位置
  */
  func getSurroundSquarePositions() -> [(Int, Int)] {
    let row = self.position.0
    let column = self.position.1
    
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
        // 「地雷チェック」モードのとき
        square.image = UIImage(named: Const.imgFlagName)
        square.state = FlagState.sharedInstance
        GameData.sharedInstance.flagUnused--
      } else {
        // マスの中身に合わせて処理を変更
        square.state = OpenState.sharedInstance

        // 「空」だった場合は、隣接マスを自動開放
        if square.bombCount == 0 {
          doAutoOpen(square)
        } else {
          println("\(square.position)、自動開放せず。")
        }
        
        // 画像の切り替え
        let bombCountType: ContentType = ContentType(rawValue: square.bombCount)!
        let imageName: String = ContentType.getImageName(bombCountType)
        square.image = UIImage(named: imageName)
      }

      GameManager.sharedInstance.judgeGameIsCleared()
    }

    /**
    タップ対象が空だった時、周囲のマスの自動開放をおこなう
    
    :param: square マスのインスタンス
    */
    private func doAutoOpen(square: Square) {
      println("\(square.position)が「空」。自動開放実行。")
      let surroundSquarePositions: [(Int, Int)] = square.getSurroundSquarePositions()
      
      for position in surroundSquarePositions {
        println("\(position)：\(square.position)による自動開放")
        let targetSquare: Square = GameData.sharedInstance.squares[position.0][position.1]
        
        // 自動開放したマスも「空」だった場合、再帰的に周囲も自動開放していく
        targetSquare.state.doTouchUp(targetSquare)
      }
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