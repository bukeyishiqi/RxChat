//
//  EmotionGroupModel.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/4.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation


enum EmotionType: Int {
    /** 直接插入文本中的小图标, 静态表情, 动态大话表情*/
    case emoji, facial, facialGif
}

struct EmotionItem {
    var text: String?
    var imagePNG: String?
    var imageGIF: String?
    var codeId: String?  // 表情ID
    
    init() {

    }
    
    init(emtionInfo: Dictionary<String, Any>) {
        self.text = emtionInfo["text"] as? String
        self.imagePNG = emtionInfo["image"] as? String
        self.imageGIF = emtionInfo["imageGIF"] as? String
        self.codeId = emtionInfo["id"] as? String
    }
}

struct EmotionGroup {
    
    var groupName: String
    var allEmotionModels: [EmotionItem]
    var groupIconName: String
    var type: EmotionType
}
