//
//  Color+Extension.swift
//  RxChat
//
//  Created by 陈琪 on 2017/6/26.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class func colorFromHex(hex: String) -> UIColor {
        assert(hex.hasPrefix("#"), "颜色字符串要以#开头")
        
        let hexString = NSString.init(string: hex).substring(from: 1)
        var hexInt: UInt32 = 0
        
        let result =  Scanner(string: hexString).scanHexInt32(&hexInt)

        guard result else {
            return UIColor.clear
        }
        
        return UIColor.init(red: (CGFloat((hexInt & 0xff0000) >> 16) / 255.0), green: (CGFloat((hexInt & 0x00ff00) >> 8) / 255.0), blue: (CGFloat(hexInt & 0x0000ff) / 255.0), alpha: 1)
    }
}
