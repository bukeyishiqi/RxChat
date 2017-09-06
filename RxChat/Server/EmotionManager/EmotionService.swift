//
//  EmotionService.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/4.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit

final class EmotionService {

    static let `default`: EmotionService  = {
        return EmotionService()
    }()
    
    var allEmotionGroups: [EmotionGroup]
    
    init() {
        self.allEmotionGroups = [EmotionGroup]()
    }
    
    // MARK: 表情包数据处理
    func prepareEmotionData() {
        guard EmotionService.default.allEmotionGroups.count <= 0 else {
            return
        }
        let path = Bundle.main.path(forResource: "Emotions", ofType: "plist")
        guard  let _ = path else { return }
        guard let groups = NSArray.init(contentsOfFile: path!) else { return }
        
        for group in groups {
            /** 初始Group下表情ItemModels*/
            
            guard let groupInfo = (group as? Dictionary<String, Any>), let emotions = groupInfo["items"] else {
                return
            }
            
            var emotionItems = [EmotionItem]()
            for itemInfo in emotions as! Array<Dictionary<String, String>> {
                let emotionModel = EmotionItem(emtionInfo: itemInfo)
                emotionItems.append(emotionModel)
            }
            
            var type: EmotionType = .emoji
            if (groupInfo["type"] as! String == "emoji") {
                type = .emoji
            } else if (groupInfo["type"] as! String == "gif") {
                type = .facialGif
            }
            
            let groupName = groupInfo["group"] as! String
            let groupIconName = groupInfo["groupicon"] as! String
            
            let groupModel = EmotionGroup.init(groupName: groupName, allEmotionModels: emotionItems, groupIconName: groupIconName, type: type)
            
            EmotionService.default.allEmotionGroups.append(groupModel)
        } 
    }
}

// MARK: 数据获取接口
extension EmotionService {
    func imageForEmotionModel(item: EmotionItem) -> UIImage? {
        guard let name = item.imagePNG else {
            return nil
        }
        
        if  let image = UIImage.init(named: name) {
            return image
        }
        
        return imageForEmotionPNGName(name: name)
    }
    
    private func imageForEmotionPNGName(name: String) -> UIImage? {
        guard let path = Bundle.main.path(forResource: "Emotion", ofType: "bundle") else {
            return nil
        }
        let bundle = Bundle.init(path: path)
        return UIImage.init(named: name, in: bundle, compatibleWith: nil)
    }
}

