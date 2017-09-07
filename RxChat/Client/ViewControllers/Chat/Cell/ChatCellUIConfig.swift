//
//  ChatCellUIConfig.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/30.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit


// MARK: 头像约束
let avatar_left = 10
let avatar_top = 5
let avatar_width_height = 45

// MARK: Bubble的约束
let bubble_top = 2
let bubble_left = 3
let bubble_bottom = 15
let bubble_lessThan_width = SCREEN_WIDTH * 0.58
let bubble_greaterThan_width = 53


let ReceiverTextNodeBkg = UIImage.init(named:"ReceiverTextNodeBkg")?.resizableImage()
let ReceiverTextNodeBkgHL = UIImage.init(named:"ReceiverTextNodeBkgHL")?.resizableImage()
let SenderTextNodeBkg = UIImage.init(named:"SenderTextNodeBkg")?.resizableImage()
let SenderTextNodeBkgHL = UIImage.init(named:"SenderTextNodeBkgHL")?.resizableImage()
let ReceiverImageNodeBorder = UIImage.init(named:"ReceiverImageNodeBorder")?.resizableImage()
let ReceiverImageNodeMask = UIImage.init(named:"ReceiverImageNodeMask")?.resizableImage()
let SenderImageNodeBorder = UIImage.init(named:"SenderImageNodeBorder")?.resizableImage()
let SenderImageNodeMask = UIImage.init(named:"SenderImageNodeMask")?.resizableImage()
