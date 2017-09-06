//
//  UIImage+Ext.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/30.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit


extension UIImage {

    public func resizableImage() -> UIImage {
        let capWidth = CGFloat(floorf(Float(self.size.width / 2)))
        let capHeight =  CGFloat(floorf(Float(self.size.height / 2)))
        
        return self.resizableImage(withCapInsets: UIEdgeInsetsMake(capHeight, capWidth, capHeight, capWidth))
    }
}
