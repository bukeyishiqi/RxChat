//
//  BSResult.swift
//  MallMobile
//
//  Created by 陈琪 on 16/10/26.
//  Copyright © 2016年 Carisok. All rights reserved.
//

import Foundation


enum BSResult {
    case success(value: Any)
    case failure(errro: BSError)
    
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    var isFailure: Bool {
        return !isSuccess
    }
}
