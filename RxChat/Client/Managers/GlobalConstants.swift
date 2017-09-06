//
//  GlobalConstants.swift
//  MallMobile
//
//  Created by 陈琪 on 2017/2/23.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation
import UIKit

final class GlobalConstants {

    fileprivate var arrayVCs: [UIViewController] = [UIViewController]()
    /** 共用资源同步处理队列*/
    fileprivate let syncQueue: DispatchQueue = DispatchQueue.init(label: "com.global.myqueue")
    
    class var shareInstance: GlobalConstants {
    
        struct Static {
            static let instance: GlobalConstants = GlobalConstants()
        }
        return Static.instance
    }
    
    init() {
        
    }
}


// MARK: -  arrayVCs数组操作

extension GlobalConstants {

    var arrayVCsCount: Int {
        return arrayVCs.count
    }
    
    // MARK: - 添加
    func append(_ vc: UIViewController) {
        syncQueue.sync { 
            arrayVCs.append(vc)
        }
    }
    
    // MARK: - 取值
    public func take(forClass `class`: AnyClass) -> UIViewController? {
        var vc: UIViewController? = nil
        for item in arrayVCs {
            if item.isMember(of: `class`) {
                vc = item
                break
            }
        }
        return vc
    }
    
    
    // MARK: - 删除
    public func remove(last: Bool = false, forVc vc: UIViewController? = nil) {
        syncQueue.sync { 
            if last == true {
                arrayVCs.removeLast()
            } else {
                if vc != nil, let value = vc {
                    let index = arrayVCs.index(of: value)
                    guard let toIndex = index else {return}
                    let range = Range(toIndex..<arrayVCs.endIndex)
                    arrayVCs.removeSubrange(range)
                }
            }
        }
    }
}







