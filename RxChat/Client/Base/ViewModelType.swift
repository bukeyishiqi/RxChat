//
//  ViewModelType.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/31.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation

public protocol ViewModelType {
    associatedtype input
    associatedtype output
    func transform(_ input: input) -> output
}
