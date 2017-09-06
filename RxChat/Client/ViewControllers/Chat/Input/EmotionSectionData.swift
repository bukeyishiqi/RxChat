//
//  EmotionSectionData.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/8.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit
import RxDataSources



let  GIF_CELL_SIZE: CGFloat =  62

let  TOP_AREA_HEIGHT: CGFloat = 170
let  BOTTOM_AREA_HEIGHT: CGFloat = 37
let  MIDDLE_AREA_HEIGHT: CGFloat = 10
let  BOTTOM_BUTTON_WIDTH: CGFloat = 45

let  ROWS_EMOJI: CGFloat = 3
let  ROWS_GIF: CGFloat = 2

struct EmotionGroupData {
    
    var group: EmotionGroup
    var sectionModels: [EmotionSectionModel]?
    
    var sectionIndex: Int?
    var totalSections: Int
    var startSection: Int?
    var pageNum: Int
    var totalItem: Int
    var itemSize: CGSize
    var sectionInset: UIEdgeInsets
    var minimumLineSpacing: CGFloat
    var minimumInteritemSpacing: CGFloat
    
    var number_per_line: Int // 每行个数
    
    init(group: EmotionGroup) {
        self.group = group
        self.totalItem = self.group.allEmotionModels.count
        self.sectionIndex = 0
        self.startSection = 0
        if self.group.type == .emoji {
            if (SCREEN_WIDTH >= 414) {
                number_per_line = 9
            }else {
                number_per_line = 8
            }
        } else {
            number_per_line = 5
        }
        
        if self.group.type == .emoji {
            let hgap = OYUtils.pixelAlignForFloat((SCREEN_WIDTH - CGFloat(number_per_line) * EMOJI_IMAGE_SIZE)/CGFloat(number_per_line + 2))
            let itemWidth = EMOJI_IMAGE_SIZE + hgap
            let itemHeight = EMOJI_IMAGE_SIZE + 18
            self.itemSize = CGSize.init(width: itemWidth, height: itemHeight)
            self.minimumLineSpacing = 0
            self.minimumInteritemSpacing = 0
            
            let hgapl = hgap
            let hgapr = SCREEN_WIDTH - CGFloat(number_per_line) * itemWidth - hgapl
            let vgapt = OYUtils.pixelAlignForFloat((TOP_AREA_HEIGHT - ROWS_EMOJI * itemHeight) / 2)
            let vgapb = TOP_AREA_HEIGHT - ROWS_EMOJI * itemHeight - vgapt
            self.sectionInset = UIEdgeInsetsMake(vgapt, hgapl, vgapb, hgapr)
            
            self.pageNum = number_per_line * Int(ROWS_EMOJI)
            self.totalSections = Int(ceilf(Float(self.totalItem) / Float(self.pageNum - 1)))
        } else {
            
            var recommendWidth = (Int(SCREEN_WIDTH) - 8 * (number_per_line + 3)) / number_per_line
            if Int(GIF_CELL_SIZE) < recommendWidth {
                recommendWidth = Int(GIF_CELL_SIZE)
            }
            
            let hgap = OYUtils.pixelAlignForFloat((SCREEN_WIDTH - CGFloat(number_per_line * recommendWidth))/CGFloat(number_per_line + 3))
            self.itemSize = CGSize.init(width: recommendWidth, height: recommendWidth + 16)
            self.minimumLineSpacing = hgap
            self.minimumInteritemSpacing = 0
            let hgapr = SCREEN_WIDTH - CGFloat(number_per_line * recommendWidth) - (CGFloat(number_per_line) + 1) * hgap
            self.sectionInset = UIEdgeInsetsMake(7, hgap * 2, 4, hgapr)
            
            self.pageNum = number_per_line * Int(ROWS_GIF)
            self.totalSections = Int(ceil(Float(self.totalItem) / Float(self.pageNum)))
            
        }
        
        self.sectionModels = self.configSectionModels()
    }
    
    private func configSectionModels() -> [EmotionSectionModel] {
        
        var sectionModels = [EmotionSectionModel]()
        
        let rowCount = self.group.type == .emoji ? ROWS_EMOJI: ROWS_GIF
        
        for i in 0..<self.totalSections {
            var models = [EmotionItem]()
            
            for j in 0..<self.pageNum {
                let row = j % Int(rowCount)
                let col = j / Int(rowCount)
                let position = number_per_line * row + col
                
                let newItem = position + (self.pageNum - 1) * i
                
                var model:EmotionItem
                
                if self.group.type == .emoji {
                    if newItem < self.totalItem {
                        if position == self.pageNum - 1 { // 删除按钮
                            model = EmotionItem()
                            model.imagePNG = "emotion_delete"
                        } else {
                            model = self.group.allEmotionModels[newItem]
                        }
                    }  else {
                        if position == self.pageNum - 1 {
                            model = EmotionItem()
                            model.imagePNG = "emotion_delete"
                        } else {
                            model = EmotionItem()
                        }
                    }
                } else {
                    if newItem < self.totalItem {
                        model = self.group.allEmotionModels[newItem]
                    } else {
                        model = EmotionItem()
                    }
                }
                
                models.append(model)

            }
            sectionModels.append(EmotionSectionModel.init(data: models))
        }
        return sectionModels
    }
    
}




struct EmotionSectionModel {
    
    var data: [EmotionItem]
}

extension EmotionSectionModel: SectionModelType {
    typealias Item  = EmotionItem
    var items: [Item] { return self.data }
    
    init(original: EmotionSectionModel, items: [Item]) {
        self = original
        self.data = items
    }
}

