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
  @IBOutlet var fieldWidth:UILabel?
  @IBOutlet var fieldHeight:UILabel?
  @IBOutlet var bombCount:UILabel?

  @IBAction func segmentChange(sender: UISegmentedControl) {
    GameData.sharedInstance.tapMode = TapMode(rawValue: sender.selectedSegmentIndex)!
  }
  
  @IBAction func changeFieldWidth(sender: UIStepper) {
    let value = Int(sender.value)
    gameData.setting.fieldWidth = value
    
    fieldWidth?.text = value.description
    
    gameManager.resetGame()
  }
  
  @IBAction func changeFieldHeight(sender: UIStepper) {
    let value = Int(sender.value)
    gameData.setting.fieldHeight = value
    fieldHeight?.text = value.description

    gameManager.resetGame()
  }
  
  @IBAction func changeBombCount(sender: UIStepper) {
    let value = Int(sender.value)
    gameData.setting.bombCount = value
    bombCount?.text = value.description
    
    gameManager.resetGame()
  }

  let gameManager = GameManager.sharedInstance
  let gameData = GameData.sharedInstance
  
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
  @IBAction func resetGame() {
    gameManager.resetGame()
  }
  
}

