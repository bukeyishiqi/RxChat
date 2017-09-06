//
//  ConversationViewModel.swift
//  RxChat
//
//  Created by 陈琪 on 2017/7/5.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import RxSwift
import RxCocoa

final class ConversationViewModel {

    let allConversationModels: Variable<[Conversation]>
    
    init() {
        let arr = ChatService.shared.loadConversationListFromDB()
        allConversationModels = Variable(arr)
    }
}
