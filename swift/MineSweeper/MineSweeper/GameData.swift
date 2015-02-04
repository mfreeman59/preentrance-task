//
//  GameData.swift
//  MineSweeper
//
//  Created by 松田 健吾 on 2015/01/22.
//  Copyright (c) 2015年 Kengo Matsuda. All rights reserved.
//

import Foundation

/**
*  ゲームに関するデータ全体を管理するクラス
*/
class GameData {
  
  /// タップ時の挙動（開くか、地雷チェックか）
  var tapMode = TapMode.Open
  
  /// 使っていない旗の数
  var flagUnused: Int
  
  /// フラグが立てられていない爆弾の数
  var bombUnflagged: Int
  
  /// フィールド上にあるマスの情報
  var squares = [[Square]]()
  
  /// ゲーム開始前に決める設定
  let setting = Setting.sharedInstance
  
  /// シングルトン取得
  class var sharedInstance : GameData {
    struct Static {
      static let instance = GameData()
    }
    return Static.instance
  }
  
  private init() {
    self.bombUnflagged = Setting.sharedInstance.bombCount
    self.flagUnused = self.bombUnflagged
  }
  
  /**
  *  ゲームを最初からやり直すため、値をリセット
  */
  func resetAllData() {
    setting.unsetBombCount = setting.bombCount
    squares.removeAll(keepCapacity: true)
    bombUnflagged = setting.bombCount
    flagUnused = setting.bombCount
  }

  /**
  *  ゲームの設定を管理するクラス
  */
  class Setting {
    
    /**
    *  合計の爆弾の数
    *　初期値：5
    */
    let bombCount: Int = 5
    
    /**
    *  マスの初期化時の残り爆弾数のカウント用
    */
    var unsetBombCount: Int
    
    /**
    *  フィールドの横幅
    *　初期値：5
    */
    let fieldWidth: Int = 5
    
    /**
    *  フィールドの縦幅
    *　初期値：5
    */
    let fieldHeight: Int = 5
    
    /**
    *  マスの数
    */
    let squareCount: Int
    
    /**
    *  マスのサイズ
    */
    let squareSize: Int = 64
    
    private init() {
      self.unsetBombCount = bombCount
      self.squareCount = fieldWidth * fieldHeight
    }
    
    /// シングルトン取得
    class var sharedInstance : Setting {
      struct Static {
        static let instance = Setting()
      }
      return Static.instance
    }
  }
  
}

