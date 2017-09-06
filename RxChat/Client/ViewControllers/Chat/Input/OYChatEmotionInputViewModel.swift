//
//  OYChatEmotionInputViewModel.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/7.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class OYChatEmotionInputViewModel {

    let disposeBag: DisposeBag = DisposeBag()
    
    var group: Variable<[EmotionGroup]>
    
    var groupData = [EmotionGroupData]()
    
    var sectionModels: Variable<[EmotionSectionModel]>?
    
    init() {
        
        let groupItems = EmotionService.default.allEmotionGroups
        group = Variable(groupItems)
        
        groupData = getSectionDatas(groups: groupItems)
        
        var sectiondata = [EmotionSectionModel]()
        groupData.forEach {
            sectiondata += $0.sectionModels!
        }
        
        sectionModels = Variable(sectiondata)
    }
        
    
    private func getSectionDatas(groups: [EmotionGroup]) -> [EmotionGroupData] {
       
        var sectionDatas = [EmotionGroupData]()
        
        var index: Int = 0
        for i in 0 ..< groups.count {
            let group = groups[i]
            var sectionData = EmotionGroupData.init(group: group)
            sectionData.startSection = index
            index += sectionData.totalSections
            sectionData.sectionIndex = i
            sectionDatas.append(sectionData)
        }
        return sectionDatas
    }
    
    func getSectionData(section: Int) -> EmotionGroupData? {
        var index = 0
        for sectionData in groupData {
            index += sectionData.totalSections
            
            if section < index {
                return sectionData
            }
        }
        return nil
    }
    
    func sectitonSizeForSection(section: Int) -> CGSize {
        let data = getSectionData(section: section)
       return data?.itemSize ?? CGSize.zero
    }
    
    func sectionEdgInsets(section: Int) -> UIEdgeInsets {
        let data = getSectionData(section: section)
        return data?.sectionInset ?? UIEdgeInsets.zero
    }
    
    func sectionMinimumLineSpacing(section: Int) -> CGFloat {
        let data = getSectionData(section: section)
        return data?.minimumLineSpacing ?? 0
    }
    
    func sectionMinimumInteritemSpacing(section: Int) -> CGFloat {
        let data = getSectionData(section: section)
        return data?.minimumInteritemSpacing ?? 0
    }
}


















