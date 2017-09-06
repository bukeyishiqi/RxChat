//
//  BSBaseManager.swift
//  MallMobile
//
//  Created by 陈琪 on 16/10/25.
//  Copyright © 2016年 Carisok. All rights reserved.
//

import Foundation

/**
 *  业务处理父类
 */

public class BSBaseManager {

    /**
     *  服务器类型
     */
   // let server: Server = .FCServer
    
    /** 网络请求完成执行闭包*/
    var completionHandler: ((_ respnse: Any, _ error: BSError) -> Void)?

}


extension BSBaseManager {
    
    // MARK: 数据加载结束统一回调
    func finish(completionHandler: @escaping (_ respnse: Any, _ error: BSError) -> Void) {
        self.completionHandler = completionHandler
    }
    
}
