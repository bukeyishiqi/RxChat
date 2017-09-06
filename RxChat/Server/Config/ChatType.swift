//
//  ChatType.swift
//  RxChat
//
//  Created by 陈琪 on 2017/7/24.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation

/** 
 * 会话类型
 */
enum ConversationType: Int {
    case singleChat = 0, groupChat
}



/**
 *  消息类别
 */
enum MsgDesType: Int {
    /** 发送、接收 */
    case receive = 0, send
}
/**
 * 消息类型
 */
enum MsgBodyType {
    case text(text: String)
    case image(item: ImageItem)
    case video(item: VideoItem)
    case location(item: LocationItem)
    case voice(item: VideoItem)
    case file(item: FileItem)
    case time(time: String)
    
    var intValue:Int {
        switch self {
        case .text(text: _):
            return 0
        case .image(item: _):
            return 1
        case .video(item: _):
            return 2
        case .voice(item: _):
            return 3
        case .file(item: _):
            return 4
        case .time(time: _):
            return 5
        default:
            return 99
        }
    }
    
    var storeValue: String {
        switch self {
        case let .text(text: text):
            return text
        case let .image(item: fileItem):
            return ""
        case let .video(item: videoItem):
            return ""
        case let .voice(item: _):
            return ""
        case let .file(item: _):
            return ""
        case let .time(time: _):
            return ""
        default:
            return ""
        }
    }
    
    var titleValue: String {
        switch self {
        case let .text(text: text):
            return text
        case let .image(item: fileItem):
            return BUBBLEMSG_CAPTUREIMG_MSG
        case let .video(item: videoItem):
            return BUBBLEMSG_VIDEO_MSG
        case let .voice(item: _):
            return BUBBLEMSG_AUDIO_MSG
        case let .file(item: _):
            return BUBBLEMSG_FILE_MSG
        case let .time(time: _):
            return ""
        default:
            return ""
        }
    }
}



enum MsgStatus: Int {
    /** 成功，发送中，发送失败， 发送完成, 已读*/
    case success = 0, delivering, sendFail, sended, readed
}
