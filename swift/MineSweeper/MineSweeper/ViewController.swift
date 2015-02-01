//
//  ViewController.swift
//  MineSweeper
//
//  Created by 松田 健吾 on 2015/01/18.
//  Copyright (c) 2015年 Kengo Matsuda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet var buttleField:UIView?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    // マスの初期化
    initButtleField()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /**
  マスの初期化
  */
  func initButtleField() {
    let setting = GameData.sharedInstance.setting;

    for i in 0..<setting.fieldWidth {
      for j in 0..<setting.fieldHeight {
        let btn = Square(position: (i, j))
        // マスの追加＆位置の決定
        buttleField?.addSubview(btn)
        btn.frame = CGRectMake(CGFloat(
          setting.squareSize * j),
          CGFloat(setting.squareSize * i),
          CGFloat(setting.squareSize),
          CGFloat(setting.squareSize)
        )
      }
    }

  }
}

