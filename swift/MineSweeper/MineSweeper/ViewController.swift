//
//  ViewController.swift
//  MineSweeper
//
//  Created by 松田 健吾 on 2015/01/18.
//  Copyright (c) 2015年 Kengo Matsuda. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameManagerDelegate {
  
  @IBOutlet var buttleField:UIView?
  @IBOutlet var switchTapMode:UISegmentedControl?
  @IBOutlet var resultView:UIView?
  @IBOutlet var resultText:UILabel?

  @IBAction func segmentChange(sender: UISegmentedControl) {
    GameData.sharedInstance.tapMode = TapMode(rawValue: sender.selectedSegmentIndex)!
  }

  let gameManager: GameManager = GameManager.sharedInstance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    // デリゲートの設定
    gameManager.delegate = self
    // マスの初期化
    gameManager.initButtleField()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  /**
  ゲームを初期化する
  */
  @IBAction func restartGame() {
    gameManager.restartGame()
  }
  
}

