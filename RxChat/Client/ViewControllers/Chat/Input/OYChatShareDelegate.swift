//
//  OYChatShareDelegate.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/9.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit

let TAG_Photo = 1
let TAG_Camera = 2
let TAG_Sight = 3
let TAG_VideoCall = 4
let TAG_Redpackage = 5
let TAG_MoneyTransfer = 6
let TAG_Location = 6
let TAG_Favorites = 7
let TAG_Card = 8
let TAG_Wallet = 9


let  NUM_ROWS: Int =  2
let NUM_COLS: Int =  4

let CELL_SIZE: CGFloat =  59


protocol OYChatShareInputViewDelegate: NSObjectProtocol {
    func shareInputViewDidSelectTag(tag: Int)
}

/** 
 * 构建显示栏固定数据
 */

func buildSharepanelData() -> [ShareInputSectionData] {
    var sectionDatas = [ShareInputSectionData]()
    
    let fixedArray = getFixedData()
    
    let section = ceilf(Float(fixedArray.count) / Float(NUM_COLS * NUM_ROWS))

    for i in 0..<Int(section) {
        var sectionItems = [ShareInputItem]()
        
        for j in 0..<NUM_ROWS*NUM_COLS {
            let row = j % NUM_ROWS
            let col = j / NUM_ROWS
            let position = NUM_COLS * row + col
            let newItem = position + (NUM_COLS * NUM_ROWS) * i
            
            var item: ShareInputItem
            if newItem < fixedArray.count {
                item = ShareInputItem(imageName: fixedArray[newItem].0, title: fixedArray[newItem].1, tag: fixedArray[newItem].2)
            } else {
                item = ShareInputItem()
            }
            sectionItems.append(item)
        }
        let sectionData = ShareInputSectionData(data: sectionItems)
        sectionDatas.append(sectionData)
    }
    
    return sectionDatas
}

func getFixedData() -> [(String, String, Int)] {

    return [ 
        ("sharemore_pic", "照片", TAG_Photo),
        ("sharemore_video", "拍摄", TAG_Camera),
        ("sharemore_sight", "小视频", TAG_Sight),
        ("sharemore_videovoip", "视频聊天", TAG_VideoCall),
        ("sharemore_wallet", "红包", TAG_Redpackage),
        ("sharemorePay", "转账", TAG_MoneyTransfer),
        ("sharemore_location", "位置", TAG_Location),
        ("sharemore_myfav", "收藏", TAG_Favorites),
        ("sharemore_friendcard", "个人名片", TAG_Card),
        ("sharemore_wallet", "卡券", TAG_Wallet)]
}





