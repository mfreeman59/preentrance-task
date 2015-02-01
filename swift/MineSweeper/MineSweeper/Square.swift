//
//  Square.swift
//  MineSweeper
//
//  Created by 松田 健吾 on 2015/02/01.
//  Copyright (c) 2015年 Kengo Matsuda. All rights reserved.
//

import UIKit

class Square : UIImageView {
  
  var state : SquareState = SquareState.Empty
  let position : (Int, Int)
  
  init(position : (Int, Int)) {

    self.position = position

    // スーパークラスのイニシャライザ
    super.init(image: UIImage(named: "btn"))
    self.userInteractionEnabled = true

    // 爆弾をセット
    if canSetBomb() {
      self.state = SquareState.Bomb
      println("Bomb is in \(position)")
    }
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if state == SquareState.Empty {
      image = UIImage(named: "btn_over")
    }
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    if state == SquareState.Empty {
      image = UIImage(named: "btn")
    } else if state == SquareState.Bomb {
      image = UIImage(named: "bomb")
    }
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
}