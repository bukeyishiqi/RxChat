//
//  ChatTextCell.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/29.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit


final class ChatTextCell: ChatBaseCell {
    
    lazy var msgTextLabel = UILabel().then {
        $0.textAlignment = .left
        $0.contentMode = .top
        $0.textColor = UIColor.black
        $0.numberOfLines = 0
        $0.font = UIFont.systemFont(ofSize: 16)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(msgTextLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var viewModel: ChatBaseCellViewModel? {
        didSet {
            guard let viewModel = viewModel as? ChatTextViewModel else {
                return
            }
            viewModel.rxTextMsg
                .asDriver(onErrorJustReturn: "text消息错误！")
                .drive(msgTextLabel.rx.text)
                .disposed(by: disposeBag!)
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        self.addConstraints()
    }
}

extension ChatTextCell {
    fileprivate func addConstraints() {
    
        msgTextLabel.snp.makeConstraints( { make in
            make.edges.equalTo(bubbleImage).inset(UIEdgeInsetsMake(10, 15, 15, 12))
        })
    }
}
