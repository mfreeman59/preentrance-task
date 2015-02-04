//
//  ContentType.swift
//  MineSweeper
//
//  Created by 松田 健吾 on 2015/02/04.
//  Copyright (c) 2015年 Kengo Matsuda. All rights reserved.
//

enum ContentType: Int {
  case Empty, One, Two, Three, Four, Five, Six, Seven, Eight, Flag, Bomb
  
  /**
  *  caseに書かれているメンバと順番を合わせる
  */
  static let imageNames = ["empty", "num_01", "num_02", "num_03", "num_04", "num_05", "num_06", "num_07", "num_08", "flag", "bomb"]
  
  /**
  中身に合わせた画像のファイル名を返す
  
  :param: type マスのタイプ
  
  :returns: 画像名
  */
  static func getImageName(type: ContentType) -> String {
    return imageNames[type.rawValue]
  }
}
