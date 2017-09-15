//
//  CustomObjectConvertibleType.swift
//  RxChat
//
//  Created by 陈琪 on 2017/9/14.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation

/** 
 * realm数据库object转换自定义object对象协议
 */
protocol CustomObjectConvertibleType {
    
    associatedtype CustomType
    
    func asCustomObject() -> CustomType
}
