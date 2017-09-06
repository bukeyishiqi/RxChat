//
//  OYUtils+Nib.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/9.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit


extension UIView {

    class func oy_viewForNib<T>(_ nibType: T.Type) -> T {
        
        let name = NSStringFromClass(nibType as! AnyClass).components(separatedBy: ".").last
        let nib = UINib(nibName: name!, bundle: nil)
        let view = nib.instantiate(withOwner: nibType, options: nil).first as! T
        return view
    }
}
