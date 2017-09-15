//
//  RealmRepresentable.swift
//  RxChat
//
//  Created by 陈琪 on 2017/9/14.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation

/** 
 * 自定义类型对象转换为Realm的object
 */
protocol RealmRepresentable {
    
    associatedtype RealmType: CustomObjectConvertibleType
    
    func asRealm() -> RealmType
}
