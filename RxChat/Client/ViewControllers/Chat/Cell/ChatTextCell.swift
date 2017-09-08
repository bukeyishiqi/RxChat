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
        bubbleView.addSubview(msgTextLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var viewModel: ChatBaseCellViewModel? {
        didSet {
            setViewModel()
        }
    }
}

extension ChatTextCell {
    fileprivate func setViewModel() {
        guard let viewModel = viewModel as? ChatTextViewModel else {
            return
        }
        viewModel.rxTextMsg
            .drive(msgTextLabel.rx.text)
            .disposed(by: disposeBag!)

        viewModel.isFromMe.subscribe(onNext: {
            self.reUpdateConstraints(isFromMe: $0)
        }).disposed(by: disposeBag!)
    }
}

extension ChatTextCell {
    fileprivate func reUpdateConstraints(isFromMe: Bool) {
        let image = isFromMe ? SenderTextNodeBkg : ReceiverTextNodeBkg
        bubbleView.image = image
        
        let contentSize = msgTextLabel.sizeThatFits(CGSize(width: bubble_lessThan_width, height: .greatestFiniteMagnitude))
        
        // 重新布局
        avatarImage.snp.remakeConstraints { (make) in
            make.width.height.equalTo(avatar_width_height)
            make.top.equalTo(self.snp.top)
        }
        bubbleView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(-bubble_top)
            make.bottom.equalTo(msgTextLabel.snp.bottom).offset(bubble_bottom)
        }
        msgTextLabel.snp.remakeConstraints { (make) in
            make.height.equalTo(contentSize.height)
            make.width.equalTo(contentSize.width)
        }
        
        if isFromMe {
            avatarImage.snp.makeConstraints { (make) in
                make.right.equalTo(self.snp.right).offset(-avatar_left)
            }
            bubbleView.snp.makeConstraints { (make) in
                make.right.equalTo(avatarImage.snp.left).offset(-bubble_left)
                make.left.equalTo(msgTextLabel.snp.left).offset(-sub_margin * 2)
            }
            msgTextLabel.snp.makeConstraints { (make) in
                make.top.equalTo(bubbleView.snp.top).offset(sub_margin)
                make.right.equalTo(bubbleView.snp.right).offset(-17)
            }

        } else {
            avatarImage.snp.makeConstraints { (make) in
                make.left.equalTo(self.snp.left).offset(sub_margin)
            }
            bubbleView.snp.makeConstraints { (make) in
                make.left.equalTo(avatarImage.snp.right).offset(bubble_left)
                make.right.equalTo(msgTextLabel.snp.right).offset(sub_margin * 2)
            }
            msgTextLabel.snp.makeConstraints { (make) in
                make.top.equalTo(bubbleView.snp.top).offset(sub_margin)
                make.left.equalTo(bubbleView.snp.left).offset(17)
            }
        }
        
        viewModel?.cellHeight = getCellHeight()
    }
}
