//
//  ChatBaseCell.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/28.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa


class ChatBaseCell: UITableViewCell {
    
    lazy var avatarImage = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = UIColor.red
    }
    
    lazy var bubbleView = UIImageView().then {
        $0.contentMode = .scaleToFill
        $0.backgroundColor = UIColor.yellow
    }
    
    var disposeBag: DisposeBag?

    var viewModel: ChatBaseCellViewModel? {
        didSet {
            let disposeBag = DisposeBag()

            guard let viewModel = viewModel else {
                return
            }
            /** 设置头像*/
            viewModel.headUrl.distinctUntilChanged()
                .subscribe(onNext: {[weak self] urlStr in
                    self?.avatarImage.image = UIImage.init(named: urlStr)
                }).disposed(by: disposeBag)
            self.disposeBag = disposeBag
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(avatarImage)
        self.addSubview(bubbleView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentView.addSubview(avatarImage)
        self.contentView.addSubview(bubbleView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
        viewModel = nil
    }
    
//    override func updateConstraints() {
//        super.updateConstraints()
//        self.updateConstraints(isFromMe: false)
//    }
}

extension ChatBaseCell {
//    fileprivate func updateConstraints(isFromMe: Bool) {
//        avatarImage.snp.makeConstraints({ make in
//            make.width.height.equalTo(avatar_width_height)
//            make.top.equalTo(self.contentView.snp.top)
//            if isFromMe {
//                make.right.equalTo(self.contentView).offset(-avatar_left)
//            } else {
//                make.left.equalTo(self.contentView).offset(avatar_left)
//            }
//        })
//        
//        bubbleImage.snp.makeConstraints( { make in
//            make.top.equalTo(avatarImage)
//            make.bottom.equalTo(self.contentView.snp.bottom)
//            if isFromMe {
//                make.right.equalTo(avatarImage.snp.left).offset(-bubble_left)
//            } else {
//                make.left.equalTo(avatarImage.snp.right).offset(bubble_left)
//            }
//            make.width.lessThanOrEqualTo(bubble_lessThan_width)
//            make.width.greaterThanOrEqualTo(bubble_greaterThan_width)
//        })
//    }
    
    // MARK:- 获取cell的高度
    func getCellHeight() -> CGFloat {
        self.layoutSubviews()
        
        if avatarImage.height > bubbleView.height {
            return avatarImage.height + 10.0
        } else {
            return bubbleView.height + 10.0
        }
    }
}




